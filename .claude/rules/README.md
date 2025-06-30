# Claude Rules for Yanolja Clone Project

This directory contains comprehensive rules and guidelines for developing the Yanolja Clone Flutter application. These rules are designed to ensure consistency, prevent common errors, and maintain high code quality.

## Rule Files Overview

### 📋 [00_project_overview.md](00_project_overview.md)
- **Core project identity and restrictions**
- **Platform support policy (mobile-only)**
- **Business domain understanding**
- **Critical platform restrictions**

### 🏗️ [01_architecture_rules.md](01_architecture_rules.md)
- **Clean Architecture implementation**
- **Dependency injection patterns**
- **UseCase and Repository patterns**
- **Provider architecture guidelines**

### ⚡ [02_development_commands.md](02_development_commands.md)
- **Required development setup sequence**
- **Platform-specific build commands**
- **Troubleshooting workflows**
- **No testing framework guidance**

### 🎨 [03_ui_ux_standards.md](03_ui_ux_standards.md)
- **Mandatory UI component measurements**
- **Animation timing standards**
- **Brand color system**
- **Accessibility requirements**

### 🔍 [04_code_quality_rules.md](04_code_quality_rules.md)
- **Static analysis compliance**
- **Import and null safety management**
- **Performance best practices**
- **Critical code review checklist**

### 📱 [05_platform_specific_rules.md](05_platform_specific_rules.md)
- **Android and iOS development rules**
- **Firebase and Google Maps configuration**
- **CocoaPods dependency management**
- **Platform deployment preparation**

### 📊 [06_data_and_state_management.md](06_data_and_state_management.md)
- **Riverpod state management patterns**
- **Mock data requirements and standards**
- **Category-specific data rules**
- **Data validation and error handling**

### 🚨 [07_error_prevention_and_debugging.md](07_error_prevention_and_debugging.md)
- **Entity-Model mapping verification**
- **Common compilation error fixes**
- **Firebase and Google Maps debugging**
- **Performance debugging strategies**

## Critical Rules Summary

### 🚫 NEVER DO
- Suggest web, Linux, Windows, or macOS platform support
- Use deprecated APIs like `.withOpacity()` (use `.withValues()`)
- Create UseCase instances directly (use DI container)
- Call `.execute()` on UseCases (use direct call syntax)
- Skip iOS `pod install` after dependency changes
- Assume Entity-Model field names match without verification
- Leave unused imports or dead code
- Use raw `print()` statements in production code

### ✅ ALWAYS DO
- Verify Clean Architecture dependency directions
- Run `flutter analyze` before committing
- Use mobile-only development patterns
- Follow UI measurement standards (42px search fields, 300ms animations)
- Implement proper error handling with Korean user messages
- Validate mock data has sufficient quantity and quality
- Use proper Riverpod provider patterns
- Dispose resources in widget lifecycle methods

## Quick Reference for Common Tasks

### New Feature Development
1. Check if using Clean Architecture pattern is required
2. Create Domain entities first, then Data models
3. Implement Repository interface and UseCase
4. Create Provider using established DI patterns
5. Build UI with mandatory standards compliance

### Bug Investigation  
1. Check ERROR_RULES.md for known patterns
2. Verify Entity-Model mapping accuracy
3. Confirm UseCase call syntax correctness
4. Run static analysis and fix warnings
5. Test on both Android and iOS platforms

### Code Review Focus
1. Clean Architecture compliance
2. Mobile platform restrictions adherence  
3. UI/UX standards conformance
4. Error handling robustness
5. Performance optimization

## Integration with ERROR_RULES.md

These rules complement the detailed error resolution patterns documented in `ERROR_RULES.md`. While these rules focus on **prevention**, ERROR_RULES.md provides **reactive solutions** to specific problems encountered during development.

For comprehensive development guidance, use these rules alongside:
- CLAUDE.md (high-level project overview)
- ERROR_RULES.md (specific error resolution patterns)
- Flutter documentation (framework specifics)

---

**Remember**: These rules are based on real development experiences and user feedback. They represent learned best practices specifically for this mobile-focused Yanolja clone project.