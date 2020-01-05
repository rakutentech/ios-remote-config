[![Build Status](https://travis-ci.org/rakutentech/ios-remote-config.svg?branch=master)](https://travis-ci.org/rakutentech/ios-remote-config)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


# Remote Config (Kotlin Multiplatform POC)

Provides remote configuration for iOS applications. The networking part of the module is provided by a Kotlin Multiplatform framework.

## Getting started

### Requirements

This module supports iOS 10.0 and above. It has been tested on iOS 10.0 and above.

It is written in Swift 5.0 and can be used in compatible Xcode versions.

### Documentation

Generated documentation for the module is hosted on rakutentech's GitHub site https://rakutentech.github.io/ios-remote-config.

### Installing

To use the module your `Podfile` should contain:

    source 'https://github.com/CocoaPods/Specs.git'

    pod 'RRemoteConfig'

Run `pod install` to install the module and its dependencies.

### Configuring

Currently we do not host any public APIs but you can create your own APIs and configure the SDK to use those.

To use the module you must set the following values in your app's `Info.plist`.

| Key     | Value     |
| :---:   | :---:     |
| `RASApplicationIdentifier` | your_app_id |
| `RASProjectSubscriptionKey` | your_subscription_key |
| `RRCConfigAPIEndpoint` | https://www.example.com |

### Get config values

- Attention: Newly fetched config values will not be available until the next app launch. This means that in the first session after app install the fallback values will be used instead of fetched values.

#### Code examples

        // Get a String value
        let testString = RemoteConfig.getString(key: "stringKeyName", fallback: "string_fallback_value")

        // Get a Boolean value
        let testBoolean = RemoteConfig.getBoolean(key: "booleanKeyName", fallback: false)

        // Get a NSNumber value
        let testNumber = RemoteConfig.getNumber(key: "numberKeyName", fallback: 1)

        // Get the entire config as a dictionary
        let configDictionary = RemoteConfig.getConfig()

## Contributing

See CONTRIBUTING.md for details of how to participate in development of the module.

#### Running the sample app and unit tests

- Clone or fork the repo
- Run `git submodule update --init` in the root which will populate the `shared` folder
- Run `cd shared` then run `git submodule update --init` to populate the `config` folder
- Run `./gradlew linkRemoteConfigSharedDebugFrameworkIos` to create the shared networking framework `build/bin/ios/RemoteConfigSharedDebugFramework/RemoteConfigShared.framework`
- Run `bundle exec pod install` in the repo root folder
- Open `RRemoteConfig.xcworkspace` in Xcode
- Select the `SampleApp` scheme then build/run
- To run the tests press key shortcut command-U

## Changelog

See CHANGELOG.md for the new features, changes and bug fixes of the module versions.
