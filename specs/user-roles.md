# User Roles & Permissions

## Customer
- Browse products and categories
- Manage shopping cart
- Place and track orders
- Manage personal profile and addresses
- View order history
- Write product reviews
- Manage payment methods

## Merchant
- Manage store settings and branding
- Configure product categories
- Select and manage suppliers
- Curate product catalog
- View sales analytics and reports
- Manage customer service
- Configure payment methods
- Set pricing and discounts
- Manage inventory rules

## Supplier
- Manage product catalog
- Update inventory levels
- Process dropship orders
- Provide tracking information
- Manage pricing and availability
- API access management
- View order statistics

## Implementation Guidelines

### Role-Based Access Control (RBAC)
- Implement granular permissions for each action
- Support role inheritance and delegation
- Audit trail for all permission changes
- Dynamic permission checking at runtime

### Security Considerations
- Multi-factor authentication for merchant and supplier accounts
- API key management for suppliers
- Session timeout and management
- Rate limiting per role type