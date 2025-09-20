---
spec_version: "1.0.1"
last_updated: "2025-09-20T14:42:00Z"
content_hash: "sha256:36ca1d20c168967db81cc585f1d44b46ab1c9955660258ca38c8500ab2da21e2"
dependencies: []
implementation_status: "completed"
code_references: []
---

# Spec-Sync Integration Guide

This document explains how the eCommerce platform uses the Spec-Sync tool for specification-driven development.

## Tool Integration

### Spec-Sync Tool Installation
The universal spec synchronization tool is a separate project available via:

#### Installation Options
```bash
# Option 1: Install from crates.io (recommended)
cargo install spec-sync

# Option 2: Install from GitHub releases
# Download binary from: https://github.com/your-org/spec-sync/releases

# Option 3: Install from source
git clone https://github.com/your-org/spec-sync
cd spec-sync
cargo install --path .
```

### Integration Commands
```bash
# Check specification sync status
spec-sync status

# Update spec metadata  
spec-sync update-metadata specs/modules/auth.md

# Add code reference
spec-sync add-ref specs/modules/auth.md src/auth/mod.rs --language rust
```

## Project Structure

### eCommerce Platform Files
```
ecommerce/
├── specs/                      # Platform specifications
│   ├── modules/               # Business logic modules
│   ├── data-models/           # Database schemas
│   ├── api/                   # API specifications
│   └── user-flows/            # User journey definitions
├── src/                       # Implementation code
│   ├── auth/                  # Authentication module
│   ├── products/              # Product management
│   └── ...                    # Other modules
├── SPECIFICATION_INDEX.md      # Master spec navigation
├── DEVELOPMENT_WORKFLOW.md     # Implementation process
└── spec-sync-tool/            # Synchronization tool
```

### Separation of Concerns

#### Spec-Sync Tool (Universal)
- **Purpose**: Generic spec-to-code synchronization
- **Scope**: Works with any project type
- **Responsibilities**:
  - Version tracking and metadata management
  - Sync status detection and reporting
  - Code reference management
  - Change validation

#### eCommerce Platform (Specific)
- **Purpose**: Modern eCommerce platform implementation
- **Scope**: Business logic and domain specifics
- **Responsibilities**:
  - Platform architecture and design
  - Business module specifications
  - API definitions and data models
  - Implementation code

## Development Workflow

### 1. Specification Updates
```bash
# Edit platform specifications
vim specs/modules/auth.md

# Tool automatically updates metadata on commit (with pre-commit hook)
git commit -m "Add new authentication features"
```

### 2. Sync Checking
```bash
# Check what needs updating
./spec-sync-tool/tools/spec-sync-simple.sh status

# Example output:
# ❌ specs/modules/auth.md@1.1.0 -> src/auth/mod.rs [OUTDATED]
# ✅ specs/modules/products.md@1.0.0 -> src/products/mod.rs [SYNCED]
```

### 3. Implementation
```bash
# Update implementation based on spec changes
# Add spec reference to new files
./spec-sync-tool/tools/spec-sync-simple.sh add-ref specs/modules/cart.md src/cart/mod.rs rust
```

## Installation Steps

### 1. One-Time Setup
```bash
# Make tools executable
chmod +x spec-sync-tool/tools/*.sh

# Install pre-commit hook (optional)
cp spec-sync-tool/tools/pre-commit-hook.sh .git/hooks/pre-commit
```

### 2. Add to Development Scripts
Add to `package.json` or `Makefile`:
```json
{
  "scripts": {
    "spec-status": "./spec-sync-tool/tools/spec-sync-simple.sh status",
    "spec-validate": "./spec-sync-tool/tools/spec-sync-simple.sh validate"
  }
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Specification Sync Check
on: [push, pull_request]

jobs:
  spec-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate Specifications
        run: |
          chmod +x spec-sync-tool/tools/*.sh
          ./spec-sync-tool/tools/spec-sync-simple.sh validate
      - name: Check Sync Status
        run: ./spec-sync-tool/tools/spec-sync-simple.sh status
```

## Benefits for eCommerce Platform

### 1. Specification-Driven Development
- Platform specifications are the single source of truth
- Implementation follows documented requirements exactly
- Changes to requirements drive code updates

### 2. Modular Development
- Each business module can be developed independently
- Clear boundaries between specifications and implementation
- Progressive implementation of platform features

### 3. Quality Assurance
- Automatic detection of implementation drift
- Validation that code matches specifications
- Clear audit trail of changes and versions

### 4. Team Collaboration
- Shared understanding of platform requirements
- Clear visibility into implementation status
- Consistent development practices across modules

## Usage Examples

### Adding New Module
```bash
# 1. Create specification
echo "# New Module Spec" > specs/modules/new-module.md
./spec-sync-tool/tools/update-spec-metadata.sh specs/modules/new-module.md

# 2. Create implementation with reference
./spec-sync-tool/tools/spec-sync-simple.sh add-ref specs/modules/new-module.md src/new-module/mod.rs rust

# 3. Verify sync
./spec-sync-tool/tools/spec-sync-simple.sh status
```

### Updating Existing Module
```bash
# 1. Edit specification
vim specs/modules/auth.md

# 2. Update metadata (automatic with pre-commit hook)
./spec-sync-tool/tools/update-spec-metadata.sh specs/modules/auth.md minor

# 3. Check what's outdated
./spec-sync-tool/tools/spec-sync-simple.sh status

# 4. Update implementation accordingly
```

## Tool Extensibility

The Spec-Sync tool can be extended for platform-specific needs:

### Custom Code Generation
Add platform-specific generators:
```bash
# Generate Rust API endpoints from API specs
./tools/generate-api-endpoints.sh specs/api/README.md

# Generate database migrations from data models
./tools/generate-migrations.sh specs/data-models/core.md
```

### Custom Validation
Add domain-specific validation:
```bash
# Validate eCommerce business rules
./tools/validate-business-rules.sh

# Check API consistency across modules
./tools/validate-api-consistency.sh
```

## Maintenance

### Tool Updates
The Spec-Sync tool can be updated independently:
```bash
# Update tool from repository
git subtree pull --prefix=spec-sync-tool origin main --squash
```

### Platform Updates
Platform specifications and implementation evolve independently from the tool:
```bash
# Platform development continues normally
git add specs/ src/
git commit -m "Implement payment processing module"
```

This separation ensures that:
- The tool remains reusable across projects
- Platform development isn't tied to tool changes
- Both can evolve independently