---
spec_version: "1.0.0"
last_updated: "2025-09-20T14:50:00Z"
content_hash: "sha256:placeholder"
dependencies: []
implementation_status: "completed"
code_references: []
---

# eCommerce Platform Installation Guide

This guide covers setting up the eCommerce platform development environment and the Spec-Sync tool.

## Prerequisites

- **Rust** 1.70+ (`rustup install stable`)
- **PostgreSQL** 14+ (for database)
- **Redis** 6+ (for caching)
- **Git** (for version control)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/ecommerce-platform
cd ecommerce-platform
```

### 2. Install Spec-Sync Tool

The Spec-Sync tool is used for specification-to-code synchronization.

#### Option A: Install from Crates.io (Recommended)
```bash
cargo install spec-sync
```

#### Option B: Install from GitHub Source
```bash
# Install directly from GitHub
cargo install --git https://github.com/your-org/spec-sync

# Or clone and install
git clone https://github.com/your-org/spec-sync
cd spec-sync
cargo install --path .
```

### 3. Verify Installation

```bash
# Check that spec-sync is available
spec-sync --version

# Check eCommerce platform specs
spec-sync status
```

### 4. Set Up Development Environment

```bash
# Install project dependencies
cargo build

# Set up database (requires PostgreSQL running)
createdb ecommerce_dev
cargo run --bin setup-db

# Set up Redis (requires Redis running)
redis-cli ping
```

## Development Workflow

### Specification-Driven Development

The platform uses specification-driven development where documentation is the source of truth:

```bash
# 1. Check current sync status
spec-sync status

# 2. Edit specifications
vim specs/modules/auth.md

# 3. Update metadata (version bump)
spec-sync update-metadata specs/modules/auth.md --version-bump minor

# 4. Implement according to spec
# ... code implementation ...

# 5. Add spec reference to code
spec-sync add-ref specs/modules/auth.md src/auth/mod.rs --language rust

# 6. Verify synchronization
spec-sync validate
```

### Common Commands

```bash
# Development
cargo run                          # Start the server
cargo test                         # Run tests
cargo watch -x run                 # Auto-reload during development

# Specification Management
spec-sync status                   # Check sync status
spec-sync validate                 # Validate all specs
spec-sync update-metadata <file>   # Update spec metadata
spec-sync add-ref <spec> <code>    # Add spec reference

# Database
cargo run --bin migrate            # Run database migrations
cargo run --bin seed               # Seed development data
```

## Project Structure

```
ecommerce-platform/
├── specs/                         # 📋 Platform specifications
│   ├── modules/                   # Business logic modules
│   ├── data-models/               # Database schemas
│   ├── api/                       # API specifications
│   └── user-flows/                # User journey definitions
├── src/                           # 🦀 Rust implementation
│   ├── auth/                      # Authentication module
│   ├── products/                  # Product management
│   ├── orders/                    # Order processing
│   └── main.rs                    # Application entry point
├── spec-sync-tool/                # 🔧 Sync tool (separate crate)
├── Cargo.toml                     # Workspace configuration
└── README.md                      # Project overview
```

## Configuration

### Environment Variables

Create a `.env` file:

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost/ecommerce_dev
REDIS_URL=redis://localhost:6379

# Server
SERVER_HOST=127.0.0.1
SERVER_PORT=8080

# External APIs
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### Development Configuration

The platform uses a modular configuration system. See `config/` directory for environment-specific settings.

## Integration with CI/CD

### GitHub Actions

The project includes GitHub Actions for:
- **Spec Validation**: Ensures all specifications are consistent
- **Sync Checking**: Verifies implementations match specifications
- **Testing**: Runs full test suite
- **Building**: Compiles and packages the application

### Pre-commit Hooks

Set up automatic spec metadata updates:

```bash
# Install pre-commit hooks
cargo install --path spec-sync-tool
cp spec-sync-tool/tools/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Development Guidelines

### 1. Specification First

Always start with updating specifications before implementation:

```bash
# ❌ Wrong: Implement then document
vim src/auth/mod.rs
vim specs/modules/auth.md

# ✅ Correct: Document then implement
vim specs/modules/auth.md
spec-sync update-metadata specs/modules/auth.md
vim src/auth/mod.rs
spec-sync add-ref specs/modules/auth.md src/auth/mod.rs
```

### 2. Incremental Development

Develop one module at a time following the specification priority:

1. **Foundation**: Authentication, Core Models
2. **Core Commerce**: Products, Cart, Orders  
3. **Integration**: Payments, Suppliers
4. **Enhancement**: Analytics, Advanced Features

### 3. Sync Validation

Regularly check that implementations match specifications:

```bash
# Before committing
spec-sync validate

# Before deploying
spec-sync status
```

## Troubleshooting

### Common Issues

#### Spec-Sync Not Found
```bash
# Ensure spec-sync is installed
cargo install spec-sync

# Or use from workspace
cargo run --bin spec-sync -- status
```

#### Database Connection Issues
```bash
# Check PostgreSQL is running
pg_isready

# Verify connection string
psql $DATABASE_URL
```

#### Redis Connection Issues
```bash
# Check Redis is running
redis-cli ping

# Should return: PONG
```

#### Outdated Specifications
```bash
# Check what's out of sync
spec-sync status

# Update metadata for changed specs
spec-sync update-metadata specs/modules/auth.md
```

### Getting Help

1. **Documentation**: Check the specification files in `specs/`
2. **Issues**: Create GitHub issues for bugs or questions
3. **Discussions**: Use GitHub Discussions for general questions
4. **Spec-Sync**: See `spec-sync-tool/README.md` for tool-specific help

## Next Steps

1. **Read the Specifications**: Start with `SPECIFICATION_INDEX.md`
2. **Follow Development Workflow**: See `DEVELOPMENT_WORKFLOW.md`
3. **Understand Tool Integration**: Read `SPEC_SYNC_INTEGRATION.md`
4. **Begin Implementation**: Start with the authentication module

---

You're now ready to start development on the eCommerce platform using specification-driven development!