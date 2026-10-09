// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"fmt"
	"net/url"
	"os"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/protobuf/encoding/protojson"

	pb "github.com/GoogleCloudPlatform/microservices-demo/src/orderhistoryservice/genproto"
)

const schema = `
CREATE TABLE IF NOT EXISTS orders (
	order_id   TEXT PRIMARY KEY,
	user_id    TEXT NOT NULL,
	email      TEXT NOT NULL,
	placed_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
	order_data JSONB NOT NULL,
	total_paid JSONB
);
CREATE INDEX IF NOT EXISTS orders_user_id_placed_at_idx ON orders (user_id, placed_at DESC);
`

const maxOrdersPerUser = 50

type store struct {
	pool *pgxpool.Pool
}

// postgresConnString builds a connection string from POSTGRES_* env vars.
func postgresConnString() string {
	host := getenv("POSTGRES_HOST", "localhost")
	port := getenv("POSTGRES_PORT", "5432")
	db := getenv("POSTGRES_DB", "postgres")
	user := getenv("POSTGRES_USER", "postgres")
	sslmode := getenv("POSTGRES_SSLMODE", "disable")

	u := url.URL{
		Scheme:   "postgres",
		User:     url.UserPassword(user, os.Getenv("POSTGRES_PASSWORD")),
		Host:     fmt.Sprintf("%s:%s", host, port),
		Path:     "/" + db,
		RawQuery: url.Values{"sslmode": {sslmode}}.Encode(),
	}
	return u.String()
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func newStore(ctx context.Context, connString string) (*store, error) {
	pool, err := pgxpool.New(ctx, connString)
	if err != nil {
		return nil, fmt.Errorf("invalid postgres configuration: %w", err)
	}

	// The database may still be starting up, so retry schema creation for a while.
	const attempts = 30
	for i := 1; ; i++ {
		_, err = pool.Exec(ctx, schema)
		if err == nil {
			break
		}
		if i == attempts {
			pool.Close()
			return nil, fmt.Errorf("failed to initialize schema: %w", err)
		}
		log.Warnf("postgres not ready (attempt %d/%d): %v", i, attempts, err)
		time.Sleep(2 * time.Second)
	}
	return &store{pool: pool}, nil
}

func (s *store) Close() { s.pool.Close() }

func (s *store) RecordOrder(ctx context.Context, req *pb.RecordOrderRequest) error {
	orderData, err := protojson.Marshal(req.GetOrder())
	if err != nil {
		return fmt.Errorf("marshal order: %w", err)
	}
	var totalPaid []byte
	if req.GetTotalPaid() != nil {
		if totalPaid, err = protojson.Marshal(req.GetTotalPaid()); err != nil {
			return fmt.Errorf("marshal total: %w", err)
		}
	}
	_, err = s.pool.Exec(ctx,
		`INSERT INTO orders (order_id, user_id, email, order_data, total_paid)
		 VALUES ($1, $2, $3, $4, $5)
		 ON CONFLICT (order_id) DO NOTHING`,
		req.GetOrder().GetOrderId(), req.GetUserId(), req.GetEmail(), orderData, totalPaid)
	return err
}

func (s *store) ListOrders(ctx context.Context, userID string) ([]*pb.HistoricalOrder, error) {
	rows, err := s.pool.Query(ctx,
		`SELECT email, placed_at, order_data, total_paid
		 FROM orders WHERE user_id = $1
		 ORDER BY placed_at DESC LIMIT $2`, userID, maxOrdersPerUser)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []*pb.HistoricalOrder
	for rows.Next() {
		var (
			email     string
			placedAt  time.Time
			orderData []byte
			totalPaid []byte
		)
		if err := rows.Scan(&email, &placedAt, &orderData, &totalPaid); err != nil {
			return nil, err
		}
		h := &pb.HistoricalOrder{Order: &pb.OrderResult{}, Email: email, PlacedAt: placedAt.Unix()}
		if err := protojson.Unmarshal(orderData, h.Order); err != nil {
			return nil, fmt.Errorf("unmarshal order: %w", err)
		}
		if len(totalPaid) > 0 {
			h.TotalPaid = &pb.Money{}
			if err := protojson.Unmarshal(totalPaid, h.TotalPaid); err != nil {
				return nil, fmt.Errorf("unmarshal total: %w", err)
			}
		}
		out = append(out, h)
	}
	return out, rows.Err()
}
