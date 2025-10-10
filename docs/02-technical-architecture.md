# Technical Architecture

This document translates the qualsystems analysis into concrete technical specifications for the AI-powered multi-storefront commerce platform.

## Technology Stack

### Backend
- **Language**: Rust 1.75+
- **Web Framework**: Axum 0.7+
- **Async Runtime**: Tokio
- **Database**: SurrealDB (graph + document database)
- **Database Client**: surrealdb-rs
- **HTTP Client**: reqwest (async)
- **Serialization**: serde, serde_json
- **Payment**: async-stripe
- **Environment**: dotenvy

### Frontend
- **Framework**: Leptos 0.6+ (server-side rendering + hydration)
- **Styling**: Tailwind CSS
- **Build Tool**: Trunk
- **WebAssembly**: wasm-bindgen

### External Services
- **AI**: Claude API (Anthropic)
- **Payment**: Stripe
- **Fulfillment**: Printify API (initial supplier)
- **Hosting**: Fly.io
- **DNS**: Cloudflare (or similar)

### Development Tools
- **Container**: Docker
- **Version Control**: Git
- **CI/CD**: GitHub Actions (future)
- **Monitoring**: (TBD - tracing/logging initially)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet/Customers                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐          ┌─────────▼────────┐
│  Storefronts   │          │  Merchant Admin  │
│   (Leptos)     │          │    (Leptos)      │
│                │          │                  │
│ - Cosmic Store │          │ - AI Chat        │
│ - Puzzle Store │          │ - Dashboard      │
│ - (Dynamic)    │          │ - Supplier Mgmt  │
└───────┬────────┘          └─────────┬────────┘
        │                             │
        └──────────────┬──────────────┘
                       │ HTTP/WS
        ┌──────────────▼──────────────────────┐
        │      Axum Backend (API Server)      │
        │                                     │
        │  ┌────────────────────────────┐   │
        │  │  Services Layer            │   │
        │  │  - Store Service           │   │
        │  │  - Product Service         │   │
        │  │  - Curation Service (AI)   │   │
        │  │  - Order Service           │   │
        │  └────────────┬───────────────┘   │
        │               │                    │
        │  ┌────────────▼───────────────┐   │
        │  │  Domain Layer              │   │
        │  │  - Product, Theme, Store   │   │
        │  │  - Supplier Trait          │   │
        │  │  - Business Logic          │   │
        │  └────────────┬───────────────┘   │
        └───────────────┼────────────────────┘
                        │
        ┌───────────────┼────────────────────┐
        │               │                    │
    ┌───▼─────┐  ┌─────▼──────┐  ┌─────────▼────────┐
    │SurrealDB│  │Claude API  │  │  External APIs   │
    │(Graph)  │  │(AI Curation│  │  - Stripe        │
    │         │  │ & Chat)    │  │  - Printify      │
    └─────────┘  └────────────┘  └──────────────────┘
```

### Data Flow Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    WRITE FLOWS                               │
└──────────────────────────────────────────────────────────────┘

1. Supplier Product Sync:
   Printify API ──→ Product Service ──→ Normalize ──→ SurrealDB
                                            │
                                            └──→ AI Analysis (metadata enrichment)

2. AI-Powered Store Creation:
   Merchant ──→ Chat Interface ──→ Claude API ──→ Curation Service
                                                        │
                                                        ▼
                                    Parse Intent + Find Products
                                                        │
                                                        ▼
                                    Create Theme + Assign Products
                                                        │
                                                        ▼
                                    Generate Store ──→ SurrealDB

3. Order Processing:
   Customer ──→ Storefront ──→ Stripe ──→ Order Service
                                             │
                                             ├──→ Save Order (SurrealDB)
                                             │
                                             └──→ Forward to Supplier API

┌──────────────────────────────────────────────────────────────┐
│                    READ FLOWS                                │
└──────────────────────────────────────────────────────────────┘

1. Storefront Rendering:
   Customer ──→ Store URL ──→ Leptos SSR ──→ Query Theme/Products
                                                    │
                                                    ▼
                                              SurrealDB (graph query)
                                                    │
                                                    ▼
                                              Render HTML + Hydrate

2. Admin Dashboard:
   Merchant ──→ Admin UI ──→ API Calls ──→ Services ──→ SurrealDB
                                                           │
                                                           ▼
                                                    Aggregate Stats
```

---

## Module Structure

### Backend (`src/`)

```
src/
├── main.rs                         # Application entry point
│
├── config/
│   ├── mod.rs                      # Configuration management
│   └── settings.rs                 # Environment variables, API keys
│
├── api/                            # HTTP API layer (Axum)
│   ├── mod.rs
│   ├── admin/
│   │   ├── mod.rs
│   │   ├── stores.rs               # Store CRUD endpoints
│   │   ├── products.rs             # Product management endpoints
│   │   ├── themes.rs               # Theme management endpoints
│   │   ├── suppliers.rs            # Supplier integration endpoints
│   │   └── chat.rs                 # AI chat WebSocket endpoint
│   ├── storefront/
│   │   ├── mod.rs
│   │   ├── catalog.rs              # Product browsing endpoints
│   │   ├── cart.rs                 # Shopping cart endpoints
│   │   └── checkout.rs             # Payment/order endpoints
│   └── webhooks/
│       ├── mod.rs
│       ├── stripe.rs               # Stripe webhook handlers
│       └── suppliers.rs            # Supplier webhook handlers
│
├── services/                       # Business logic layer
│   ├── mod.rs
│   ├── store_service.rs            # Store creation, management, generation
│   ├── product_service.rs          # Product import, sync, normalization
│   ├── curation_service.rs         # AI-powered product curation
│   ├── order_service.rs            # Order processing and fulfillment
│   ├── theme_service.rs            # Theme management
│   └── supplier_service.rs         # Supplier API orchestration
│
├── domain/                         # Core business models
│   ├── mod.rs
│   ├── product.rs                  # Product entity and logic
│   ├── theme.rs                    # Theme entity and logic
│   ├── store.rs                    # Store entity and logic
│   ├── order.rs                    # Order entity and logic
│   ├── supplier.rs                 # Supplier trait definition
│   ├── customer.rs                 # Customer entity
│   └── common.rs                   # Shared types (Money, Id, etc.)
│
├── suppliers/                      # Supplier adapters
│   ├── mod.rs                      # Supplier trait + registry
│   ├── printify/
│   │   ├── mod.rs
│   │   ├── client.rs               # Printify API client
│   │   ├── models.rs               # Printify-specific types
│   │   └── adapter.rs              # Supplier trait implementation
│   └── generic/
│       └── template.rs             # Template for new suppliers
│
├── ai/                             # AI integration
│   ├── mod.rs
│   ├── claude.rs                   # Claude API client
│   ├── prompts/
│   │   ├── mod.rs
│   │   ├── curation.rs             # Product curation prompts
│   │   ├── chat.rs                 # Store creation chat prompts
│   │   └── analysis.rs             # Product analysis prompts
│   └── models.rs                   # AI request/response types
│
├── db/                             # Database layer
│   ├── mod.rs
│   ├── connection.rs               # SurrealDB connection pool
│   ├── schema.rs                   # Database schema definitions
│   ├── queries/
│   │   ├── mod.rs
│   │   ├── products.rs             # Product queries
│   │   ├── themes.rs               # Theme queries
│   │   ├── stores.rs               # Store queries
│   │   └── orders.rs               # Order queries
│   └── migrations/                 # Schema migrations (if needed)
│       └── mod.rs
│
└── utils/                          # Shared utilities
    ├── mod.rs
    ├── error.rs                    # Error types and handling
    ├── validation.rs               # Input validation
    └── logging.rs                  # Logging configuration
```

### Frontend (`ui/`)

```
ui/
├── src/
│   ├── main.rs                     # Leptos app entry
│   │
│   ├── admin/                      # Merchant admin interface
│   │   ├── mod.rs
│   │   ├── app.rs                  # Main admin app component
│   │   ├── dashboard.rs            # Overview dashboard
│   │   ├── chat.rs                 # AI chat interface
│   │   ├── stores/
│   │   │   ├── mod.rs
│   │   │   ├── list.rs             # Store list view
│   │   │   └── detail.rs           # Store detail/edit
│   │   ├── products/
│   │   │   ├── mod.rs
│   │   │   ├── catalog.rs          # Product catalog browser
│   │   │   └── detail.rs           # Product detail/edit
│   │   ├── themes/
│   │   │   ├── mod.rs
│   │   │   ├── list.rs             # Theme list
│   │   │   └── editor.rs           # Theme editor
│   │   └── suppliers/
│   │       ├── mod.rs
│   │       ├── list.rs             # Connected suppliers
│   │       └── add.rs              # Add new supplier
│   │
│   ├── storefront/                 # Customer-facing storefronts
│   │   ├── mod.rs
│   │   ├── app.rs                  # Storefront app component
│   │   ├── catalog.rs              # Product catalog view
│   │   ├── product.rs              # Product detail page
│   │   ├── cart.rs                 # Shopping cart
│   │   ├── checkout.rs             # Checkout flow
│   │   └── order_confirmation.rs   # Order confirmation page
│   │
│   ├── shared/                     # Shared UI components
│   │   ├── mod.rs
│   │   ├── button.rs               # Button component
│   │   ├── input.rs                # Input components
│   │   ├── modal.rs                # Modal dialog
│   │   ├── card.rs                 # Card component
│   │   └── layout.rs               # Layout components
│   │
│   ├── api/                        # Frontend API clients
│   │   ├── mod.rs
│   │   ├── admin.rs                # Admin API client
│   │   ├── store.rs                # Storefront API client
│   │   └── types.rs                # Shared API types
│   │
│   └── utils/
│       ├── mod.rs
│       └── formatting.rs           # Format helpers (currency, dates)
│
├── styles/
│   └── tailwind.css                # Tailwind configuration
│
└── index.html                      # HTML entry point
```

---

## Database Schema (SurrealDB)

### Node Types (Tables)

```surrealql
-- Suppliers
DEFINE TABLE supplier SCHEMAFULL;
DEFINE FIELD name ON supplier TYPE string;
DEFINE FIELD api_type ON supplier TYPE string;  -- "printify", "printful", etc.
DEFINE FIELD credentials ON supplier TYPE object;  -- encrypted
DEFINE FIELD status ON supplier TYPE string;  -- "active", "inactive", "error"
DEFINE FIELD last_sync ON supplier TYPE datetime;
DEFINE FIELD created_at ON supplier TYPE datetime;
DEFINE INDEX supplier_name ON supplier COLUMNS name UNIQUE;

-- Products
DEFINE TABLE product SCHEMAFULL;
DEFINE FIELD supplier_id ON product TYPE record(supplier);
DEFINE FIELD external_id ON product TYPE string;  -- ID from supplier
DEFINE FIELD title ON product TYPE string;
DEFINE FIELD description ON product TYPE string;
DEFINE FIELD images ON product TYPE array<string>;
DEFINE FIELD price ON product TYPE object;  -- {amount: number, currency: string}
DEFINE FIELD variants ON product TYPE array<object>;
DEFINE FIELD availability ON product TYPE string;  -- "in_stock", "out_of_stock"
DEFINE FIELD metadata ON product TYPE object;  -- supplier-specific data
DEFINE FIELD ai_tags ON product TYPE array<string>;  -- AI-generated tags
DEFINE FIELD created_at ON product TYPE datetime;
DEFINE FIELD updated_at ON product TYPE datetime;
DEFINE INDEX product_title ON product COLUMNS title SEARCH;
DEFINE INDEX product_supplier ON product COLUMNS supplier_id, external_id UNIQUE;

-- Themes
DEFINE TABLE theme SCHEMAFULL;
DEFINE FIELD name ON theme TYPE string;
DEFINE FIELD slug ON theme TYPE string;
DEFINE FIELD description ON theme TYPE string;
DEFINE FIELD curation_criteria ON theme TYPE object;  -- AI curation rules
DEFINE FIELD aesthetic_rules ON theme TYPE object;  -- styling preferences
DEFINE FIELD created_at ON theme TYPE datetime;
DEFINE FIELD updated_at ON theme TYPE datetime;
DEFINE INDEX theme_slug ON theme COLUMNS slug UNIQUE;

-- Stores
DEFINE TABLE store SCHEMAFULL;
DEFINE FIELD name ON store TYPE string;
DEFINE FIELD domain ON store TYPE string;  -- subdomain or custom
DEFINE FIELD theme_id ON store TYPE record(theme);
DEFINE FIELD config ON store TYPE object;  -- store-specific config
DEFINE FIELD branding ON store TYPE object;  -- colors, logo, etc.
DEFINE FIELD status ON store TYPE string;  -- "draft", "live", "archived"
DEFINE FIELD created_at ON store TYPE datetime;
DEFINE FIELD updated_at ON store TYPE datetime;
DEFINE INDEX store_domain ON store COLUMNS domain UNIQUE;

-- Customers
DEFINE TABLE customer SCHEMAFULL;
DEFINE FIELD email ON customer TYPE string;
DEFINE FIELD name ON customer TYPE string;
DEFINE FIELD phone ON customer TYPE option<string>;
DEFINE FIELD address ON customer TYPE option<object>;
DEFINE FIELD created_at ON customer TYPE datetime;
DEFINE INDEX customer_email ON customer COLUMNS email UNIQUE;

-- Orders
DEFINE TABLE order SCHEMAFULL;
DEFINE FIELD order_number ON order TYPE string;
DEFINE FIELD store_id ON order TYPE record(store);
DEFINE FIELD customer_id ON order TYPE record(customer);
DEFINE FIELD line_items ON order TYPE array<object>;
DEFINE FIELD subtotal ON order TYPE object;  -- {amount, currency}
DEFINE FIELD shipping ON order TYPE object;
DEFINE FIELD tax ON order TYPE object;
DEFINE FIELD total ON order TYPE object;
DEFINE FIELD stripe_payment_id ON order TYPE string;
DEFINE FIELD status ON order TYPE string;  -- "pending", "paid", "fulfilled", "cancelled"
DEFINE FIELD fulfillment ON order TYPE array<object>;  -- supplier fulfillment records
DEFINE FIELD created_at ON order TYPE datetime;
DEFINE FIELD updated_at ON order TYPE datetime;
DEFINE INDEX order_number ON order COLUMNS order_number UNIQUE;
```

### Edge Types (Relationships)

```surrealql
-- Product belongs to Supplier
DEFINE TABLE provides SCHEMAFULL;
DEFINE FIELD in ON provides TYPE record(supplier);
DEFINE FIELD out ON provides TYPE record(product);

-- Product assigned to Theme (many-to-many)
DEFINE TABLE curates SCHEMAFULL;
DEFINE FIELD in ON curates TYPE record(theme);
DEFINE FIELD out ON curates TYPE record(product);
DEFINE FIELD assigned_by ON curates TYPE string;  -- "ai" or "manual"
DEFINE FIELD confidence_score ON curates TYPE option<float>;  -- if AI-assigned
DEFINE FIELD is_featured ON curates TYPE bool DEFAULT false;
DEFINE FIELD custom_description ON curates TYPE option<string>;
DEFINE FIELD custom_price ON curates TYPE option<object>;
DEFINE FIELD assigned_at ON curates TYPE datetime;

-- Store displays Theme
DEFINE TABLE displays SCHEMAFULL;
DEFINE FIELD in ON displays TYPE record(store);
DEFINE FIELD out ON displays TYPE record(theme);

-- Order placed at Store
DEFINE TABLE placed_at SCHEMAFULL;
DEFINE FIELD in ON placed_at TYPE record(order);
DEFINE FIELD out ON placed_at TYPE record(store);

-- Order placed by Customer
DEFINE TABLE placed_by SCHEMAFULL;
DEFINE FIELD in ON placed_by TYPE record(order);
DEFINE FIELD out ON placed_by TYPE record(customer);
```

### Example Graph Queries

```surrealql
-- Get all products in a theme
SELECT * FROM product WHERE ->curates<-theme.slug = "cosmic";

-- Get all products for a store (via theme)
SELECT * FROM product
WHERE ->curates<-theme<-displays<-store.domain = "cosmic-threads.example.com";

-- Get featured products for a theme
SELECT * FROM product WHERE ->curates[WHERE is_featured = true]<-theme.id = $theme_id;

-- Get store with products
SELECT *,
  ->displays->theme.name AS theme_name,
  ->displays->theme->curates->product AS products
FROM store WHERE domain = $domain;

-- Get order with customer and line items details
SELECT *,
  ->placed_by->customer AS customer,
  ->placed_at->store AS store
FROM order WHERE order_number = $order_number;
```

---

## Core Trait Definitions

### Supplier Trait

```rust
use async_trait::async_trait;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NormalizedProduct {
    pub external_id: String,
    pub title: String,
    pub description: String,
    pub images: Vec<String>,
    pub price: Money,
    pub variants: Vec<ProductVariant>,
    pub availability: AvailabilityStatus,
    pub metadata: serde_json::Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Money {
    pub amount: i64,  // cents
    pub currency: String,  // "USD", etc.
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProductVariant {
    pub id: String,
    pub name: String,
    pub price: Money,
    pub available: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AvailabilityStatus {
    InStock,
    OutOfStock,
    Discontinued,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FulfillmentRequest {
    pub order_id: String,
    pub line_items: Vec<LineItem>,
    pub shipping_address: Address,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FulfillmentResponse {
    pub supplier_order_id: String,
    pub status: String,
    pub tracking_url: Option<String>,
}

#[async_trait]
pub trait Supplier: Send + Sync {
    /// Authenticate with supplier API
    async fn authenticate(&self, credentials: &serde_json::Value) -> Result<(), SupplierError>;

    /// Fetch all products from supplier
    async fn fetch_products(&self) -> Result<Vec<NormalizedProduct>, SupplierError>;

    /// Sync inventory (check availability/pricing changes)
    async fn sync_inventory(&self, product_ids: Vec<String>) -> Result<Vec<NormalizedProduct>, SupplierError>;

    /// Create order with supplier for fulfillment
    async fn create_order(&self, request: FulfillmentRequest) -> Result<FulfillmentResponse, SupplierError>;

    /// Get order status from supplier
    async fn get_order_status(&self, supplier_order_id: &str) -> Result<FulfillmentResponse, SupplierError>;

    /// Get supplier name
    fn name(&self) -> &str;
}

#[derive(Debug, thiserror::Error)]
pub enum SupplierError {
    #[error("Authentication failed: {0}")]
    AuthenticationFailed(String),

    #[error("API request failed: {0}")]
    ApiError(String),

    #[error("Network error: {0}")]
    NetworkError(#[from] reqwest::Error),

    #[error("Serialization error: {0}")]
    SerializationError(#[from] serde_json::Error),
}
```

---

## API Endpoints

### Admin API

```
Authentication: Bearer token (JWT or API key)

GET    /api/admin/stores                    # List all stores
POST   /api/admin/stores                    # Create store
GET    /api/admin/stores/:id                # Get store details
PUT    /api/admin/stores/:id                # Update store
DELETE /api/admin/stores/:id                # Delete/archive store

GET    /api/admin/products                  # List products (with filters)
GET    /api/admin/products/:id              # Get product details
PUT    /api/admin/products/:id              # Update product (custom fields)

GET    /api/admin/themes                    # List themes
POST   /api/admin/themes                    # Create theme
GET    /api/admin/themes/:id                # Get theme details
PUT    /api/admin/themes/:id                # Update theme
DELETE /api/admin/themes/:id                # Delete theme

POST   /api/admin/themes/:id/curate         # AI-curate products for theme
POST   /api/admin/themes/:id/products       # Manually add product to theme
DELETE /api/admin/themes/:id/products/:pid  # Remove product from theme

GET    /api/admin/suppliers                 # List connected suppliers
POST   /api/admin/suppliers                 # Add new supplier
GET    /api/admin/suppliers/:id             # Get supplier details
PUT    /api/admin/suppliers/:id             # Update supplier credentials
DELETE /api/admin/suppliers/:id             # Disconnect supplier
POST   /api/admin/suppliers/:id/sync        # Trigger product sync

GET    /api/admin/orders                    # List orders
GET    /api/admin/orders/:id                # Get order details

WS     /api/admin/chat                      # WebSocket for AI chat
```

### Storefront API

```
No authentication required (public)

GET    /api/store/:domain/products          # List products for store
GET    /api/store/:domain/products/:id      # Get product details
GET    /api/store/:domain/theme             # Get store theme/config

POST   /api/store/:domain/cart              # Add to cart (session-based)
GET    /api/store/:domain/cart              # Get cart
DELETE /api/store/:domain/cart/:item        # Remove from cart

POST   /api/store/:domain/checkout          # Create Stripe checkout session
POST   /api/store/:domain/orders            # Create order (after payment)
GET    /api/store/:domain/orders/:id        # Get order status (with token)
```

### Webhook Endpoints

```
POST   /api/webhooks/stripe                 # Stripe payment webhooks
POST   /api/webhooks/supplier/:name         # Supplier-specific webhooks
```

---

## AI Integration

### Claude API Usage

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize)]
pub struct CurationRequest {
    pub theme_name: String,
    pub theme_description: String,
    pub available_products: Vec<ProductSummary>,
    pub max_selections: usize,
}

#[derive(Debug, Serialize)]
pub struct ProductSummary {
    pub id: String,
    pub title: String,
    pub description: String,
    pub price: String,
}

#[derive(Debug, Deserialize)]
pub struct CurationResponse {
    pub selected_products: Vec<SelectedProduct>,
    pub reasoning: String,
}

#[derive(Debug, Deserialize)]
pub struct SelectedProduct {
    pub product_id: String,
    pub confidence_score: f32,
    pub reason: String,
    pub suggested_description: Option<String>,
}
```

### Curation Prompt Template

```
You are a product curator helping create a themed online store.

Theme: {theme_name}
Description: {theme_description}

Available Products ({count}):
{product_list}

Task: Select the {max_selections} products that best fit this theme.

For each selection provide:
1. Product ID
2. Confidence score (0.0-1.0) indicating how well it fits the theme
3. Brief reason for selection
4. Optional: Suggested description tailored to the theme

Respond in JSON format:
{
  "selected_products": [
    {
      "product_id": "...",
      "confidence_score": 0.95,
      "reason": "...",
      "suggested_description": "..."
    }
  ],
  "reasoning": "Overall curation strategy..."
}
```

### Chat Interface Prompt

```
You are an AI assistant helping a merchant create and manage themed online stores.

The merchant can ask you to:
- Create a new store with a theme (e.g., "Create a cosmic-themed store")
- Find products matching a theme
- Analyze content sources (blogs, etc.) to identify products
- Manage existing stores

Context:
- Connected suppliers: {supplier_list}
- Available products: {product_count}
- Existing stores: {store_list}

Respond conversationally and offer to take actions. When creating stores or curating products,
be proactive and provide previews before finalizing.

User: {user_message}
```

---

## Deployment Architecture

### Docker Configuration

```dockerfile
# Dockerfile
FROM rust:1.75 as builder
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y libssl3 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/ecommerce-platform /usr/local/bin/
EXPOSE 8080
CMD ["ecommerce-platform"]
```

### Fly.io Configuration

```toml
# fly.toml
app = "ecommerce-platform"
primary_region = "sjc"

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "8080"

[[services]]
  internal_port = 8080
  protocol = "tcp"

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

  [[services.http_checks]]
    interval = "10s"
    timeout = "2s"
    path = "/health"

[mounts]
  source = "data"
  destination = "/data"
```

### Environment Variables

```bash
# .env.example
DATABASE_URL=ws://localhost:8000
CLAUDE_API_KEY=sk-ant-...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
PRINTIFY_API_KEY=...
RUST_LOG=info
PORT=8080
```

---

## Security Considerations

### API Key Management
- Store encrypted in database using encryption-at-rest
- Never log credentials
- Rotate keys regularly
- Use environment variables for sensitive config

### Authentication
- JWT tokens for admin API
- Session-based auth for storefronts (cart persistence)
- API key authentication for supplier webhooks

### Payment Security
- PCI compliance via Stripe (never store card data)
- HTTPS everywhere
- CSRF protection on forms
- Webhook signature verification

### Input Validation
- Validate all user inputs
- Sanitize HTML/SQL injection attempts
- Rate limiting on API endpoints
- CORS configuration for frontend

---

## Performance Considerations

### Caching Strategy
- Product catalog cached (invalidate on sync)
- Theme queries cached
- Storefront pages cached (SSR + CDN)
- API responses with ETags

### Database Optimization
- Indexes on frequently queried fields
- Graph query optimization
- Connection pooling
- Async operations throughout

### Frontend Performance
- Server-side rendering (Leptos)
- Code splitting
- Image optimization
- Lazy loading

---

## Monitoring & Observability

### Logging
- Structured logging with `tracing`
- Log levels: ERROR, WARN, INFO, DEBUG
- Request/response logging
- Performance metrics

### Metrics (Future)
- Request latency
- Database query performance
- AI API call duration
- Order processing time
- Error rates

### Alerts (Future)
- Failed payment processing
- Supplier API errors
- Database connection issues
- High error rates

---

## Next Steps

This technical architecture provides the foundation for implementation. Refer to:
- **03-development-roadmap.md** for phased implementation plan
- **04-data-model.md** for detailed database schema examples

The architecture is designed to be:
- **Lean**: Minimal complexity, leverage existing tools
- **Scalable**: Can grow from single-user to multi-tenant
- **Maintainable**: Clear separation of concerns
- **Adaptable**: Plugin architecture for suppliers and themes
