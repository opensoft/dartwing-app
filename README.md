# DartWing Flutter Mobile

A Flutter mobile application for business application scaffolding, built on the DartWing open-source framework. This app provides enterprise-grade mobile solutions with Keycloak authentication, multi-tenant architecture, and comprehensive business workflows.

## 📱 About DartWing

DartWing is an open-source Flutter framework designed for mobile business application scaffolding. The project consists of:

- **Flutter Mobile App** (this repository) - Main mobile application
- **Gatekeeper Service** - .NET backend API service 
- **Shared Flutter Library** - Core functionality, networking, and UI components

### Key Features
- 🔐 **Keycloak Authentication** - Enterprise-grade security
- 🏢 **Multi-tenant Architecture** - Site-based data isolation
- 🌐 **Multi-backend Support** - DartWing API and Healthcare (Frappe) integration
- 📊 **Business Workflows** - Organization management, document repository, barcode scanning
- 🌍 **Internationalization** - English and German language support
- 📱 **Cross-platform** - iOS and Android support

## 🚀 Quick Start (Warp Terminal - Recommended)

```bash
# Navigate to app directory (you're already here!)
cd /home/brett/projects/dartwingers/dartwing/app

# Check container status
beam-me-up status

# Start the development environment
beam-me-up start

# Connect to containerized environment
beam-me-up connect
```

## 📋 Prerequisites

### Required Software
- **Docker** - Container runtime for development environment
- **VS Code** with "Dev Containers" extension
- **Node.js** (LTS version) - Required for DevContainer CLI
- **DevContainer CLI** - `npm install -g @devcontainers/cli`
- **Git** with SSH keys configured for Azure DevOps
- **Warp Terminal** (recommended) - Enhanced development workflow

### Complete Setup
- **Windows Users**: See [Windows Setup Guide](WINDOWS-SETUP-GUIDE.md)
- **WSL Users**: This project is optimized for WSL/Linux environments

## 🛠 Development Environment

This project uses a fully containerized development environment with:

- **Flutter SDK 3.24.0** - Latest stable Flutter version
- **Android SDK** with emulator support
- **Dart SDK ^3.9.0** - Modern Dart language features
- **Warpified environment** with Flutter shortcuts and productivity tools
- **Shared ADB server** - Streamlined Android device debugging
- **Hot reload** on port 8080
- **DevTools** on port 9100

### Container Configuration
- **Memory**: 4GB allocated
- **CPU**: 2 cores allocated  
- **Network**: Connected to `dartnet` shared infrastructure
- **Project Stack**: `dartwingers` (groups with gatekeeper service)

## 🏗 Project Architecture

### Directory Structure
```
app/
├── lib/
│   ├── dart_wing/           # Symlinked shared library
│   │   ├── core/             # Core utilities and data models
│   │   ├── network/          # Network layer and API clients
│   │   ├── gui/              # Shared UI components
│   │   └── localization/     # i18n support
│   └── main.dart             # App entry point
├── .devcontainer/            # Development container configuration
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
└── test/                     # Unit and widget tests
```

### Tech Stack
- **Framework**: Flutter 3.24.0
- **Language**: Dart ^3.9.0
- **State Management**: Stateful widgets with global singletons
- **Authentication**: Keycloak via `keycloak_wrapper`
- **Networking**: HTTP with retry logic and comprehensive logging
- **Localization**: `easy_localization` (EN/DE support)
- **Barcode Scanning**: `mobile_scanner`
- **Image Processing**: TensorFlow Lite integration

## 🔧 Development Workflow

### Starting Development
1. **Start containers**: `beam-me-up start`
2. **Connect to environment**: `beam-me-up connect`  
3. **Install dependencies**: `flutter pub get`
4. **Run the app**: `flutter run`

### Common Commands (Inside Container)
```bash
# Install dependencies
flutter pub get

# Run the app with hot reload
flutter run --hot

# Run tests
flutter test

# Generate code (JSON serialization)
flutter packages pub run build_runner build

# Analyze code quality
flutter analyze

# Format code
flutter format lib/
```

### Working with Multiple Services
This app works alongside the DartWing gatekeeper service:
- **Flutter App**: `dartwing-app` (port 8080)
- **Gatekeeper API**: `dartwing-gatekeeper` (port 5000)
- Both services run in the `dartwingers` Docker stack

## 🦄 Testing

### Unit & Widget Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Integration Tests ✅
```bash
# Run integration tests locally
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart

# Run on specific device
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d <device-id>
```

**Test Coverage:**
- ✅ Environment & Framework validation
- ✅ Device features (package info, platform detection)
- ✅ Form validation & input handling
- ✅ UI component integration
- ✅ Navigation & user workflows
- ⚠️ App-specific tests (requires submodule)

## 🛠️ CI/CD Pipeline ✅

### Current Status: **ALL SYSTEMS OPERATIONAL** 🎉

**Automated Testing & Deployment:**
- ✅ **PR Checks**: Code quality, unit tests, security scanning
- ✅ **CI Pipeline**: Full integration testing on Android emulators
- ✅ **Multi-Device Testing**: Android API 29 & 30 with different device profiles
- ✅ **Intelligent Submodule Handling**: Graceful degradation for external contributors
- ✅ **Automatic Retries**: Robust handling of emulator instabilities

### **Workflow Triggers**
- **Pull Requests**: Full PR checks + integration tests
- **Push to main/develop**: Complete CI pipeline with APK builds
- **Manual dispatch**: On-demand workflow execution

### **Build Artifacts**
- **Debug APK**: Available for testing
- **Release APK**: Signed and ready for distribution
- **Test Reports**: Detailed integration test results
- **Build Skipped**: When submodule access isn't available (normal for forks)

### **For Contributors**

**External Contributors (Forks)**:
```
✅ Code Quality: PASS
✅ Unit Tests: PASS  
✅ Integration Tests: PASS (core tests)
⏭️ Build APK: Skipped (expected - no submodule access)
🎉 Overall: SUCCESS
```

**Internal Team (Full Access)**:
```
✅ Code Quality: PASS
✅ Unit Tests: PASS
✅ Integration Tests: PASS (full suite)
✅ Build APK: SUCCESS (debug + release)
🎉 Overall: FULL SUCCESS
```

### **CI Configuration Files**
- `.github/workflows/ci.yml` - Main CI pipeline
- `.github/workflows/pr-checks.yml` - Fast PR validation
- `docs/CI_SETUP.md` - Detailed CI documentation
- `docs/INTEGRATION_TESTING.md` - Integration test strategy

**For detailed CI setup and troubleshooting, see [CI Setup Guide](docs/CI_SETUP.md)**

## 🚀 Building and Deployment

### Android Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### iOS Build
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## 🌐 Environment Configuration

### Multi-Environment Support
- **QA Environment**: `https://*-qa.tech-corps.com`
- **Production Environment**: `https://*.opensoft.one`
- **Debug Mode**: Automatic QA mode detection

### Configuration Files
- **Container Config**: `.devcontainer/.env`
- **Flutter Config**: `pubspec.yaml`
- **Docker Compose**: `docker-compose.yml`, `docker-compose.override.yml`

## 📚 Documentation

### Project Documentation
- [Windows Setup Guide](WINDOWS-SETUP-GUIDE.md) - Complete Windows development setup
- [Project Architecture](../arch.md) - Detailed architecture documentation
- [Main Project README](../README.md) - Orchestrator setup and multi-repository workflow

### External Resources
- [Flutter Documentation](https://docs.flutter.dev/) - Official Flutter documentation
- [Flutter Cookbook](https://docs.flutter.dev/cookbook) - Code examples and patterns
- [Keycloak Documentation](https://www.keycloak.org/documentation) - Authentication setup

## 🔧 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check Docker status
docker ps -a

# Rebuild container
beam-me-up rebuild
```

**Flutter dependencies issues:**
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

**ADB connection problems:**
```bash
# Check shared ADB server
docker ps | grep shared-adb-server

# Restart ADB
adb kill-server
adb start-server
```

**Hot reload not working:**
- Ensure you're running `flutter run` from inside the container
- Check that port 8080 is accessible
- Verify VS Code is connected to the container

## 🤝 Contributing

### Development Process
1. **Work in feature branches** - Never commit directly to `main` or `develop`
2. **Follow Flutter conventions** - Use `flutter format` and `flutter analyze`
3. **Write tests** - Maintain test coverage for new features
4. **Update documentation** - Keep README and code comments current

### Code Standards
- Follow [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful commit messages
- Maintain backwards compatibility where possible
- Document public APIs

## 📊 Project Status

- **Version**: 1.0.2
- **Flutter SDK**: 3.24.0
- **Dart SDK**: ^3.9.0
- **Platform Support**: Android ✅, iOS ✅, Linux ✅
- **Development Status**: Active development

## 🔗 Related Projects

- **[DartWing Gatekeeper](../gatekeeper/)** - .NET backend API service
- **[DartWing Flutter Library](../lib/)** - Shared Flutter components
- **[Project Orchestrator](../)** - Multi-repository setup and coordination

---

**🌟 Enhanced with Warp Terminal integration for the ultimate Flutter development experience!**
