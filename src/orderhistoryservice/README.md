# orderhistoryservice

gRPC service (`hipstershop.OrderHistoryService`) that stores placed orders in
PostgreSQL and returns a shopper's past orders.

- `RecordOrder` — called by `checkoutservice` after an order is placed.
- `ListOrders` — called by `frontend` to render the `/orders` page.

## Configuration

| Env var             | Default     |
|---------------------|-------------|
| `PORT`              | `7080`      |
| `POSTGRES_HOST`     | `localhost` |
| `POSTGRES_PORT`     | `5432`      |
| `POSTGRES_DB`       | `postgres`  |
| `POSTGRES_USER`     | `postgres`  |
| `POSTGRES_PASSWORD` | (empty)     |
| `POSTGRES_SSLMODE`  | `disable`   |

The `orders` table is created automatically on startup.

Regenerate protos with `./genproto.sh`.
