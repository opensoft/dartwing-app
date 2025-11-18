# Environment Detection

This utility provides functionality to detect whether the application is running in a cloud/CI environment.

## Features

The `EnvironmentDetector` class provides the following capabilities:

- **CI Detection**: Detect if running in any CI/CD environment
- **GitHub Actions Detection**: Specifically detect GitHub Actions
- **Azure Pipelines Detection**: Specifically detect Azure Pipelines  
- **Cloud Detection**: General detection for any cloud-based CI platform
- **Platform Information**: Get the name of the detected platform
- **Environment Info**: Retrieve detailed environment information

## Usage

```dart
import 'package:dart_wing_mobile/utils/environment_detector.dart';

// Check if running in CI
bool isCI = EnvironmentDetector.isRunningInCI;

// Check if running in GitHub Actions
bool isGitHub = EnvironmentDetector.isRunningInGitHubActions;

// Check if running in any cloud environment
bool isCloud = EnvironmentDetector.isRunningInCloud;

// Get platform name
String platform = EnvironmentDetector.ciPlatform;
// Returns: 'GitHub Actions', 'Azure Pipelines', 'CI (Unknown)', or 'Local'

// Get detailed environment information
Map<String, String> info = EnvironmentDetector.environmentInfo;
```

## Command Line Tool

Run the environment detection script:

```bash
dart run lib/utils/check_cloud_environment.dart
```

This will output detailed information about the current environment.

## Testing

Tests are available in `test/utils/environment_detector_test.dart`:

```bash
flutter test test/utils/environment_detector_test.dart
```

## Environment Variables

The detector checks the following environment variables:

- `CI` - Generic CI indicator (should be 'true')
- `GITHUB_ACTIONS` - GitHub Actions indicator (should be 'true')
- `TF_BUILD` - Azure Pipelines indicator (should be 'True')
- `RUNNER_OS` - Operating system of the runner
- `RUNNER_ENVIRONMENT` - Environment type (e.g., 'github-hosted')

## Use Cases

This utility can be used to:

1. **Adjust logging behavior** - More verbose logging in CI environments
2. **Skip certain tests** - Skip UI tests or tests requiring specific resources in CI
3. **Configure test timeouts** - Longer timeouts in CI environments
4. **Feature flags** - Enable/disable features based on environment
5. **Analytics** - Different analytics behavior in CI vs production

## Example: Adjusting Behavior Based on Environment

```dart
import 'package:dart_wing_mobile/utils/environment_detector.dart';

void setupLogging() {
  if (EnvironmentDetector.isRunningInCloud) {
    // Enable verbose logging in CI
    Logger.level = LogLevel.debug;
  } else {
    // Normal logging in local development
    Logger.level = LogLevel.info;
  }
}

void runTests() {
  if (EnvironmentDetector.isRunningInCI) {
    // Increase timeouts in CI
    testTimeout = Duration(minutes: 5);
  } else {
    testTimeout = Duration(minutes: 2);
  }
}
```

## Answer to "Is this task running in cloud?"

When running in GitHub Actions, the detector will return:
- `isRunningInCI`: **true**
- `isRunningInGitHubActions`: **true**
- `isRunningInCloud`: **true**
- `ciPlatform`: **"GitHub Actions"**

✅ **YES - The task IS running in the cloud (GitHub Actions)**
