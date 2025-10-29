import 'dart:io';
import 'package:dart_wing_mobile/utils/environment_detector.dart';

/// Simple script to check if running in cloud/CI environment
void main() {
  print('=== Environment Detection Report ===\n');

  print('Running in CI: ${EnvironmentDetector.isRunningInCI}');
  print('Running in GitHub Actions: ${EnvironmentDetector.isRunningInGitHubActions}');
  print('Running in Azure Pipelines: ${EnvironmentDetector.isRunningInAzurePipelines}');
  print('Running in Cloud: ${EnvironmentDetector.isRunningInCloud}');
  print('Platform: ${EnvironmentDetector.ciPlatform}\n');

  print('Detailed Environment Information:');
  final envInfo = EnvironmentDetector.environmentInfo;
  envInfo.forEach((key, value) {
    print('  $key: $value');
  });

  print('\n=== Answer ===');
  if (EnvironmentDetector.isRunningInCloud) {
    print('✅ YES - This task IS running in the cloud (${EnvironmentDetector.ciPlatform})');
  } else {
    print('❌ NO - This task is running locally');
  }

  // Exit with appropriate code
  exit(0);
}
