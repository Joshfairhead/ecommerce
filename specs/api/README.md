---
spec_version: "1.0.0"
last_updated: "2025-09-20T14:20:40Z"
content_hash: "sha256:c556cab5d2817222c5af7c448fd2a0e200881620b1ed04b270e6bb5fb57dc966"
dependencies: []
implementation_status: "not_started"
code_references: []
---

# API Specifications

## Overview
RESTful API design for the eCommerce platform with consistent patterns, proper HTTP status codes, and comprehensive error handling.

## Base Structure
- **Base URL**: `https://api.platform.com/v1`
- **Authentication**: JWT Bearer tokens
- **Content-Type**: `application/json`
- **Rate Limiting**: Per endpoint and user role
- **Versioning**: URL path versioning (/v1, /v2, etc.)

## API Endpoints

### Authentication Endpoints
```yaml
POST   /auth/register         # User registration
POST   /auth/login            # User login
POST   /auth/logout           # User logout
POST   /auth/refresh          # Refresh JWT token
POST   /auth/forgot-password  # Password reset request
POST   /auth/reset-password   # Reset password with token
GET    /auth/me               # Get current user info
PUT    /auth/profile          # Update user profile
```

### Store Management (Merchant)
```yaml
GET    /stores                # List merchant's stores
POST   /stores                # Create new store
GET    /stores/{store_id}     # Get store details
PUT    /stores/{store_id}     # Update store
DELETE /stores/{store_id}     # Delete store
PUT    /stores/{store_id}/settings  # Update store settings
PUT    /stores/{store_id}/theme     # Update store theme
```

### Product Management
```yaml
GET    /stores/{store_id}/products     # List store products
POST   /stores/{store_id}/products     # Create product
GET    /products/{product_id}          # Get product details
PUT    /products/{product_id}          # Update product
DELETE /products/{product_id}          # Delete product
POST   /products/{product_id}/variants # Add product variant
PUT    /products/{product_id}/images   # Upload product images
GET    /products/search                # Search products
```

### Categories
```yaml
GET    /stores/{store_id}/categories   # List categories
POST   /stores/{store_id}/categories   # Create category
GET    /categories/{category_id}       # Get category
PUT    /categories/{category_id}       # Update category
DELETE /categories/{category_id}       # Delete category
```

### Supplier Integration
```yaml
GET    /suppliers                      # List connected suppliers
POST   /suppliers/connect              # Connect new supplier
GET    /suppliers/{supplier_id}        # Get supplier details
DELETE /suppliers/{supplier_id}        # Disconnect supplier
GET    /suppliers/{supplier_id}/products    # List supplier products
POST   /suppliers/{supplier_id}/import      # Import selected products
POST   /suppliers/{supplier_id}/sync        # Trigger product sync
```

### Shopping Cart
```yaml
GET    /cart                    # Get current cart
POST   /cart/items              # Add item to cart
PUT    /cart/items/{item_id}    # Update cart item
DELETE /cart/items/{item_id}    # Remove item from cart
DELETE /cart                    # Clear cart
POST   /cart/coupons            # Apply coupon code
```

### Checkout & Orders
```yaml
POST   /checkout/calculate      # Calculate totals (tax, shipping)
POST   /checkout/process        # Process order
GET    /orders                  # List user's orders
GET    /orders/{order_id}       # Get order details
POST   /orders/{order_id}/cancel    # Cancel order
POST   /orders/{order_id}/refund    # Request refund
PUT    /orders/{order_id}/tracking  # Update tracking info
```

### Customer Account
```yaml
GET    /account/profile         # Get user profile
PUT    /account/profile         # Update user profile
GET    /account/addresses       # List user addresses
POST   /account/addresses       # Add new address
PUT    /account/addresses/{id}  # Update address
DELETE /account/addresses/{id}  # Delete address
GET    /account/payment-methods # List payment methods
POST   /account/payment-methods # Add payment method
DELETE /account/payment-methods/{id} # Remove payment method
```

### Webhooks
```yaml
POST   /webhooks/supplier/{supplier_id}    # Supplier webhook events
POST   /webhooks/payment/{provider}        # Payment provider webhooks
POST   /webhooks/shipping/{provider}       # Shipping provider webhooks
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request data is invalid",
    "details": {
      "field_errors": {
        "email": ["Email is required", "Email format is invalid"]
      }
    }
  },
  "meta": {
    "request_id": "req_12345",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

## HTTP Status Codes

- `200 OK` - Successful GET, PUT, or DELETE
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE with no response body
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Invalid or missing authentication
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource conflict (duplicate, etc.)
- `422 Unprocessable Entity` - Validation errors
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

## Authentication

### JWT Token Structure
```json
{
  "sub": "user_id",
  "role": "merchant",
  "store_id": "store_id",
  "exp": 1640995200,
  "iat": 1640908800
}
```

### Authorization Header
```
Authorization: Bearer <jwt_token>
```

## Rate Limiting

- **Default**: 1000 requests/hour per IP
- **Authenticated**: 5000 requests/hour per user
- **Merchant**: 10000 requests/hour
- **Supplier API**: 50000 requests/hour

## Pagination

Query parameters:
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 20, max: 100)
- `sort` - Sort field (default: created_at)
- `order` - Sort order (asc/desc, default: desc)

## Filtering and Search

Query parameters:
- `q` - General search query
- `category` - Filter by category
- `price_min` / `price_max` - Price range
- `status` - Filter by status
- `date_from` / `date_to` - Date range

## Webhooks

### Event Types
- `order.created`
- `order.updated`
- `order.cancelled`
- `payment.completed`
- `payment.failed`
- `inventory.updated`
- `product.created`
- `product.updated`

### Webhook Payload
```json
{
  "event": "order.created",
  "data": {
    // Event-specific data
  },
  "webhook_id": "webhook_12345",
  "timestamp": "2024-01-01T00:00:00Z"
}
```