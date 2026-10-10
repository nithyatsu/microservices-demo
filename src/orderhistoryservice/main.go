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
	"net"
	"os"
	"time"

	"github.com/sirupsen/logrus"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/status"

	pb "github.com/GoogleCloudPlatform/microservices-demo/src/orderhistoryservice/genproto"
)

const defaultPort = "7080"

var log *logrus.Logger

func init() {
	log = logrus.New()
	log.Level = logrus.DebugLevel
	log.Formatter = &logrus.JSONFormatter{
		FieldMap: logrus.FieldMap{
			logrus.FieldKeyTime:  "timestamp",
			logrus.FieldKeyLevel: "severity",
			logrus.FieldKeyMsg:   "message",
		},
		TimestampFormat: time.RFC3339Nano,
	}
	log.Out = os.Stdout
}

type orderHistoryService struct {
	pb.UnimplementedOrderHistoryServiceServer
	store *store
}

func main() {
	ctx := context.Background()

	port := defaultPort
	if p := os.Getenv("PORT"); p != "" {
		port = p
	}

	st, err := newStore(ctx, postgresConnString())
	if err != nil {
		log.Fatalf("failed to initialize order store: %v", err)
	}
	defer st.Close()

	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", port))
	if err != nil {
		log.Fatal(err)
	}

	srv := grpc.NewServer()
	pb.RegisterOrderHistoryServiceServer(srv, &orderHistoryService{store: st})
	healthpb.RegisterHealthServer(srv, health.NewServer())

	log.Infof("starting to listen on tcp: %q", lis.Addr().String())
	log.Fatal(srv.Serve(lis))
}

func (s *orderHistoryService) RecordOrder(ctx context.Context, req *pb.RecordOrderRequest) (*pb.Empty, error) {
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	if req.GetOrder().GetOrderId() == "" {
		return nil, status.Error(codes.InvalidArgument, "order.order_id is required")
	}
	if err := s.store.RecordOrder(ctx, req); err != nil {
		log.Errorf("failed to record order %q: %v", req.GetOrder().GetOrderId(), err)
		return nil, status.Error(codes.Internal, "failed to record order")
	}
	log.Infof("[RecordOrder] user_id=%q order_id=%q", req.GetUserId(), req.GetOrder().GetOrderId())
	return &pb.Empty{}, nil
}

func (s *orderHistoryService) ListOrders(ctx context.Context, req *pb.ListOrdersRequest) (*pb.ListOrdersResponse, error) {
	if req.GetUserId() == "" {
		return nil, status.Error(codes.InvalidArgument, "user_id is required")
	}
	orders, err := s.store.ListOrders(ctx, req.GetUserId())
	if err != nil {
		log.Errorf("failed to list orders for %q: %v", req.GetUserId(), err)
		return nil, status.Error(codes.Internal, "failed to list orders")
	}
	return &pb.ListOrdersResponse{Orders: orders}, nil
}
