---
spec_version: "1.0.0"
last_updated: "2025-09-20T15:00:00Z"
content_hash: "sha256:placeholder"
dependencies: []
implementation_status: "completed"
code_references: []
---

# External Tool Usage - Proper Separation

This document explains the proper architecture where the Spec-Sync tool is completely separate from the eCommerce platform.

## ✅ **Correct Architecture**

### **📦 Spec-Sync Tool (Separate Project)**
- **Repository**: `https://github.com/your-org/spec-sync`
- **Distribution**: Published to crates.io as `spec-sync`
- **Installation**: `cargo install spec-sync`
- **Scope**: Universal tool for ANY project type

### **🛒 eCommerce Platform (This Project)**
- **Repository**: `https://github.com/your-org/ecommerce-platform`
- **Dependencies**: Uses externally installed `spec-sync` tool
- **Scope**: Specific eCommerce business logic and requirements

## 🔄 **Usage Pattern**

### **For Development Teams**
```bash
# 1. Install the tool globally (once)
cargo install spec-sync

# 2. Use in eCommerce project
cd ecommerce-platform
spec-sync status
spec-sync validate

# 3. Use in OTHER projects too
cd my-blog-project
spec-sync status

cd my-api-project  
spec-sync status
```

### **For CI/CD Pipelines**
```yaml
# .github/workflows/spec-validation.yml
name: Validate Specifications
on: [push, pull_request]

jobs:
  spec-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
      
      # Install external tool
      - name: Install spec-sync
        run: cargo install spec-sync
      
      # Use tool in this project
      - name: Validate specifications
        run: spec-sync validate
      
      - name: Check sync status
        run: spec-sync status
```

## 📁 **Project Structure Comparison**

### **❌ Before (Embedded Tool)**
```
ecommerce-platform/
├── spec-sync-tool/           # ❌ Tool embedded in project
│   ├── Cargo.toml
│   ├── src/
│   └── tools/
├── specs/                    # ✅ Platform specifications
├── src/                      # ✅ Platform implementation
└── Cargo.toml               # ❌ Workspace with tool
```

### **✅ After (External Tool)**
```
ecommerce-platform/
├── specs/                    # ✅ Platform specifications
├── src/                      # ✅ Platform implementation
├── Cargo.toml               # ✅ Clean project dependencies
├── INSTALLATION.md          # ✅ Instructions to install external tool
└── README.md                # ✅ Project-specific documentation

# Separately:
spec-sync/                    # ✅ Completely separate project
├── Cargo.toml               # ✅ Tool-specific configuration
├── src/
├── README.md
└── LICENSE
```

## 🎯 **Benefits Achieved**

### **1. True Separation of Concerns**
- **Tool development** and **platform development** are independent
- Tool can evolve without affecting eCommerce platform
- Platform can evolve without affecting tool

### **2. Reusability**
- Tool works with blogs, APIs, mobile apps, any project
- No duplication across projects
- Standard installation pattern

### **3. Maintenance**
- eCommerce team doesn't maintain sync tool
- Tool has its own repository, issues, releases
- Clear ownership boundaries

### **4. Distribution**
- Tool published to crates.io like any Rust tool
- Semantic versioning independent of platform
- Easy installation for any user

## 🔧 **Tool Development Workflow**

### **For Tool Maintainers**
```bash
# Work on spec-sync tool
git clone https://github.com/your-org/spec-sync
cd spec-sync

# Make changes
vim src/main.rs

# Test
cargo test

# Release
git tag v1.1.0
git push --tags
cargo publish  # Publishes to crates.io
```

### **For Platform Developers**
```bash
# Work on eCommerce platform
git clone https://github.com/your-org/ecommerce-platform
cd ecommerce-platform

# Install/update external tool
cargo install spec-sync --force

# Use tool for platform development
spec-sync status
vim specs/modules/auth.md
spec-sync update-metadata specs/modules/auth.md
```

## 📦 **Distribution Models**

### **Cargo (Rust Ecosystem)**
```bash
cargo install spec-sync
```

### **GitHub Releases (Pre-built Binaries)**
```bash
# Download from https://github.com/your-org/spec-sync/releases
curl -L https://github.com/your-org/spec-sync/releases/download/v1.0.0/spec-sync-linux.tar.gz
```

### **NPM (JavaScript Ecosystem)**
```bash
npm install -g spec-sync
```

### **Homebrew (macOS)**
```bash
brew install your-org/tap/spec-sync
```

## 🎉 **Final Result**

The eCommerce platform now:
- ✅ **Has zero tool maintenance burden**
- ✅ **Uses a standard external dependency**
- ✅ **Follows industry best practices**
- ✅ **Enables tool reuse across projects**
- ✅ **Maintains clean project boundaries**

This is the correct way to structure reusable development tools!

## 🔗 **Related Projects Using This Pattern**

Similar patterns in the Rust ecosystem:
- `cargo-watch` - External tool for watching file changes
- `cargo-expand` - External tool for macro expansion
- `ripgrep` - External tool for searching
- `fd` - External tool for finding files

The eCommerce platform now follows the same pattern: using external tools rather than embedding them.