# https://github.com/jcampbell05/xcake
# http://www.rubydoc.info/github/jcampbell05/xcake/master/file/docs/Cakefile.md

iOSdeploymentTarget = "10.0"
currentSwiftVersion = "5.0"
companyIdentifier = "com.rakuten.tech"
project.name = "RRemoteConfig"
project.organization = "Rakuten, Inc."

project.all_configurations.each do |configuration|
    configuration.settings["CURRENT_PROJECT_VERSION"] = "1" # just default non-empty value
    configuration.settings["DEFINES_MODULE"] = "YES" # http://stackoverflow.com/a/27251979
    configuration.settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"
    configuration.settings["ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES"] = "$(inherited)" # "YES"
    configuration.settings["SWIFT_VERSION"] = currentSwiftVersion
end

target do |target|

    target.name = "SampleApp"
    target.language = :swift
    target.type = :application
    target.platform = :ios
    target.deployment_target = iOSdeploymentTarget
    target.scheme(target.name)

    target.all_configurations.each do |configuration|
        configuration.product_bundle_identifier = companyIdentifier + "." + target.name
        configuration.supported_devices = :universal
        configuration.settings["INFOPLIST_FILE"] = "Sample/Info.plist"
        configuration.settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
    end

    target.include_files = ["Sample/**/*.*"]
    # target.include_files << "Res/**/*.*"  # add another value

    unit_tests_for target do |unit_test_target|

        unit_test_target.name = "UnitTests"
        unit_test_target.scheme(unit_test_target.name) do |scheme|
            scheme.test_configuration = "UnitTests"
        end

        unit_test_target.all_configurations.each do |configuration|
            configuration.settings["INFOPLIST_FILE"] = "Tests/Unit/" + unit_test_target.name + "-Info.plist"
        end

        unit_test_target.include_files = ["Tests/Unit/*.swift"]

    end

    unit_tests_for target do |functional_test_target|

        functional_test_target.name = "FunctionalTests"
        functional_test_target.scheme(functional_test_target.name) do |scheme|
            scheme.test_configuration = "FunctionalTests"
        end

        functional_test_target.all_configurations.each do |configuration|
            configuration.settings["INFOPLIST_FILE"] = "Tests/Functional/" + functional_test_target.name + "-Info.plist"
        end

        functional_test_target.include_files = ["Tests/Functional/*.swift"]

    end

    unit_tests_for target do |test_target|

        test_target.name = "Tests"
        test_target.scheme(test_target.name) do |scheme|
            scheme.test_configuration = "Tests"
        end

        test_target.all_configurations.each do |configuration|
            configuration.settings["INFOPLIST_FILE"] = "Tests/" + test_target.name + "-Info.plist"
        end

        test_target.include_files = ["Tests/Unit/*.swift", "Tests/Functional/*.swift"]

    end

end
