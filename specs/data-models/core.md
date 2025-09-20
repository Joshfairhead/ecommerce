---
spec_version: "1.0.0"
last_updated: "2025-09-20T14:20:40Z"
content_hash: "sha256:97f0138e8dcd1da2a838af109e7fc5836cc0be42ba4dad949ddd1e990fdff4c0"
dependencies: []
implementation_status: "not_started"
code_references: []
---

# Core Data Models

## User Entity

```rust
use uuid::Uuid;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub email: String,
    pub username: String,
    pub password_hash: String,
    pub role: UserRole,
    pub profile: UserProfile,
    pub is_verified: bool,
    pub last_login: Option<DateTime<Utc>>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub enum UserRole {
    Customer,
    Merchant,
    Supplier,
    Admin,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserProfile {
    pub first_name: Option<String>,
    pub last_name: Option<String>,
    pub phone: Option<String>,
    pub avatar_url: Option<String>,
    pub timezone: Option<String>,
    pub language: Option<String>,
}
```

## Store Entity

```rust
#[derive(Debug, Serialize, Deserialize)]
pub struct Store {
    pub id: Uuid,
    pub merchant_id: Uuid,
    pub name: String,
    pub slug: String,
    pub domain: Option<String>,
    pub description: Option<String>,
    pub logo_url: Option<String>,
    pub settings: StoreSettings,
    pub theme: Theme,
    pub status: StoreStatus,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub enum StoreStatus {
    Active,
    Inactive,
    Suspended,
    Pending,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct StoreSettings {
    pub currency: String,
    pub timezone: String,
    pub tax_inclusive: bool,
    pub inventory_tracking: bool,
    pub allow_backorders: bool,
    pub checkout_terms_required: bool,
    pub guest_checkout_enabled: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Theme {
    pub name: String,
    pub primary_color: String,
    pub secondary_color: String,
    pub custom_css: Option<String>,
    pub layout_config: serde_json::Value,
}
```

## Address Entity

```rust
#[derive(Debug, Serialize, Deserialize)]
pub struct Address {
    pub id: Uuid,
    pub user_id: Uuid,
    pub address_type: AddressType,
    pub first_name: String,
    pub last_name: String,
    pub company: Option<String>,
    pub address_line_1: String,
    pub address_line_2: Option<String>,
    pub city: String,
    pub state: String,
    pub postal_code: String,
    pub country: String,
    pub phone: Option<String>,
    pub is_default: bool,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub enum AddressType {
    Shipping,
    Billing,
    Both,
}
```

## Database Schema

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('Customer', 'Merchant', 'Supplier', 'Admin')),
    profile JSONB NOT NULL DEFAULT '{}',
    is_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stores table
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    merchant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    domain VARCHAR(255) UNIQUE,
    description TEXT,
    logo_url VARCHAR(500),
    settings JSONB NOT NULL DEFAULT '{}',
    theme JSONB NOT NULL DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Active', 'Inactive', 'Suspended', 'Pending')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Addresses table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('Shipping', 'Billing', 'Both')),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company VARCHAR(255),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(3) NOT NULL,
    phone VARCHAR(20),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_stores_merchant_id ON stores(merchant_id);
CREATE INDEX idx_stores_status ON stores(status);
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
```

## Validation Rules

### User Validation
- Email must be valid format and unique
- Username must be 3-50 characters, alphanumeric + underscore
- Password must meet security requirements (handled separately)
- Phone numbers follow E.164 format

### Store Validation
- Store name must be 1-255 characters
- Slug must be URL-safe and unique
- Domain must be valid FQDN format
- Currency must be valid ISO 4217 code

### Address Validation
- Required fields cannot be empty
- Postal codes validated by country
- Country codes must be ISO 3166-1 alpha-3