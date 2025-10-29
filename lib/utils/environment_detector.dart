import 'dart:io';

/// Utility class to detect the runtime environment
class EnvironmentDetector {
  /// Checks if the application is running in a CI/CD environment
  static bool get isRunningInCI {
    return Platform.environment.containsKey('CI') &&
        Platform.environment['CI'] == 'true';
  }

  /// Checks if the application is running in GitHub Actions
  static bool get isRunningInGitHubActions {
    return Platform.environment.containsKey('GITHUB_ACTIONS') &&
        Platform.environment['GITHUB_ACTIONS'] == 'true';
  }

  /// Checks if the application is running in Azure Pipelines
  static bool get isRunningInAzurePipelines {
    return Platform.environment.containsKey('TF_BUILD') &&
        Platform.environment['TF_BUILD'] == 'True';
  }

  /// Checks if the application is running in a cloud environment
  /// (GitHub Actions, Azure Pipelines, or other CI systems)
  static bool get isRunningInCloud {
    return isRunningInCI ||
        isRunningInGitHubActions ||
        isRunningInAzurePipelines;
  }

  /// Returns the name of the CI/CD platform
  static String get ciPlatform {
    if (isRunningInGitHubActions) {
      return 'GitHub Actions';
    } else if (isRunningInAzurePipelines) {
      return 'Azure Pipelines';
    } else if (isRunningInCI) {
      return 'CI (Unknown)';
    }
    return 'Local';
  }

  /// Returns detailed environment information
  static Map<String, String> get environmentInfo {
    return {
      'isCI': isRunningInCI.toString(),
      'isGitHubActions': isRunningInGitHubActions.toString(),
      'isAzurePipelines': isRunningInAzurePipelines.toString(),
      'isCloud': isRunningInCloud.toString(),
      'platform': ciPlatform,
      'runner': Platform.environment['RUNNER_OS'] ?? 'N/A',
      'runnerEnvironment':
          Platform.environment['RUNNER_ENVIRONMENT'] ?? 'N/A',
    };
  }
}
