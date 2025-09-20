#!/bin/bash

# Demo: Separated Architecture - Spec-Sync Tool vs eCommerce Platform

echo "🏗️  SEPARATED ARCHITECTURE DEMONSTRATION"
echo "========================================"
echo

echo "📦 SPEC-SYNC TOOL (Universal)"
echo "------------------------------"
echo "Repository: https://github.com/your-org/spec-sync"
echo "Purpose: Generic specification-to-code synchronization"
echo "Scope: Works with ANY project"
echo "Installation: cargo install spec-sync"
echo

echo "🛒 ECOMMERCE PLATFORM (Specific)"
echo "--------------------------------"
echo "Location: ./specs/, ./src/"
echo "Purpose: Modern eCommerce platform"
echo "Scope: Business logic and domain specifics"
echo
echo "Specification Structure:"
find specs -name "*.md" | head -6 | awk '{print "  - " $1}'
echo "  ... (and more)"
echo

echo "🔗 INTEGRATION"
echo "--------------"
echo "The eCommerce platform USES the Spec-Sync tool:"
echo
echo "# Check eCommerce spec synchronization"
echo "spec-sync status"
echo
echo "# Update eCommerce spec metadata"
echo "spec-sync update-metadata specs/modules/auth.md"
echo
echo "# Add code reference for eCommerce implementation"
echo "spec-sync add-ref specs/modules/auth.md src/auth/mod.rs --language rust"
echo

echo "✅ BENEFITS OF SEPARATION"
echo "-------------------------"
echo "1. 🔄 Reusability: Spec-Sync tool can be used by OTHER projects"
echo "2. 🔧 Maintenance: Tool and platform evolve independently"
echo "3. 📦 Distribution: Tool can be packaged and shared separately"
echo "4. 🎯 Focus: Each component has a single responsibility"
echo "5. 🔗 Integration: Clear boundaries and interfaces"
echo

echo "🚀 DEMONSTRATION"
echo "----------------"
echo "Running Spec-Sync tool on eCommerce platform specs:"
echo

# Run the actual sync check (would work if spec-sync was installed)
echo "📊 Specification Synchronization Status"
echo "======================================="
echo "✅ specs/modules/auth.md@1.1.0 -> src/auth/mod.rs [SYNCED]"
echo "✅ specs/modules/products.md@1.0.0 [NO_IMPLEMENTATION]"
echo "✅ specs/api/README.md@1.0.0 [NO_IMPLEMENTATION]"
echo "... (showing example output)"

echo
echo "💡 This demonstrates:"
echo "   - Universal tool checking project-specific specs"
echo "   - Clean separation between tool and domain logic"
echo "   - Tool works regardless of project type (eCommerce, blog, API, etc.)"