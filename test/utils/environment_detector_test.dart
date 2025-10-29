import 'package:flutter_test/flutter_test.dart';
import 'package:dart_wing_mobile/utils/environment_detector.dart';

void main() {
  group('EnvironmentDetector', () {
    test('should detect CI environment', () {
      // When running in GitHub Actions CI=true is set
      // This test verifies the detector works correctly
      final isCI = EnvironmentDetector.isRunningInCI;
      final isCloud = EnvironmentDetector.isRunningInCloud;
      final platform = EnvironmentDetector.ciPlatform;
      final envInfo = EnvironmentDetector.environmentInfo;

      // In CI, these should be true
      // In local development, these might be false
      expect(isCI, isA<bool>());
      expect(isCloud, isA<bool>());
      expect(platform, isA<String>());
      expect(envInfo, isA<Map<String, String>>());

      // Verify environment info structure
      expect(envInfo.containsKey('isCI'), true);
      expect(envInfo.containsKey('isGitHubActions'), true);
      expect(envInfo.containsKey('isAzurePipelines'), true);
      expect(envInfo.containsKey('isCloud'), true);
      expect(envInfo.containsKey('platform'), true);
      expect(envInfo.containsKey('runner'), true);
      expect(envInfo.containsKey('runnerEnvironment'), true);
    });

    test('should detect GitHub Actions environment when in CI', () {
      final isGitHubActions = EnvironmentDetector.isRunningInGitHubActions;
      expect(isGitHubActions, isA<bool>());

      // If running in GitHub Actions, verify correct detection
      if (isGitHubActions) {
        expect(EnvironmentDetector.ciPlatform, 'GitHub Actions');
        expect(EnvironmentDetector.isRunningInCloud, true);
      }
    });

    test('should detect Azure Pipelines environment when applicable', () {
      final isAzure = EnvironmentDetector.isRunningInAzurePipelines;
      expect(isAzure, isA<bool>());

      // If running in Azure Pipelines, verify correct detection
      if (isAzure) {
        expect(EnvironmentDetector.ciPlatform, 'Azure Pipelines');
        expect(EnvironmentDetector.isRunningInCloud, true);
      }
    });

    test('should return consistent environment information', () {
      final envInfo1 = EnvironmentDetector.environmentInfo;
      final envInfo2 = EnvironmentDetector.environmentInfo;

      // Environment info should be consistent across calls
      expect(envInfo1['isCI'], envInfo2['isCI']);
      expect(envInfo1['platform'], envInfo2['platform']);
    });

    test('platform name should match detection state', () {
      final platform = EnvironmentDetector.ciPlatform;
      final isGitHub = EnvironmentDetector.isRunningInGitHubActions;
      final isAzure = EnvironmentDetector.isRunningInAzurePipelines;
      final isCI = EnvironmentDetector.isRunningInCI;

      if (isGitHub) {
        expect(platform, 'GitHub Actions');
      } else if (isAzure) {
        expect(platform, 'Azure Pipelines');
      } else if (isCI) {
        expect(platform, 'CI (Unknown)');
      } else {
        expect(platform, 'Local');
      }
    });
  });
}
