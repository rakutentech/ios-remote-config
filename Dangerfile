# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

xcov.report(
  workspace: 'RRemoteConfig.xcworkspace',
  scheme: 'Tests',
  output_directory: 'artifacts/unit-tests/coverage',
  source_directory: 'RRemoteConfig',
  json_report: true,
  include_targets: 'RRemoteConfig.framework',
  include_test_targets: false,
  minimum_coverage_percentage: 70.0
)
