![Cocoapods](https://img.shields.io/cocoapods/v/RRemoteConfig)
[![Build Status](https://travis-ci.org/rakutentech/ios-remote-config.svg?branch=master)](https://travis-ci.org/rakutentech/ios-remote-config)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


# Remote Config

Provides remote configuration for iOS applications.

## How it works

The module fetches a JSON config from the backend API at launch time and caches the config locally if the payload signature verification succeeds. The config is fetched and cached every 60 minutes by default.

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

| Key     | Value (String type)    |
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

## Advanced features

### Configure polling delay
The polling delay (which defaults to 60 mins) can, optionally, be configured in the app's `Info.plist`:

| Key     | Value (Number type)    |
| :---:   | :---:     |
| `RRCConfigFetchPollingDelayInSeconds` | delay in seconds |

Note that the minimum polling delay is 60 seconds. If you try to set a lower value, the polling delay will be 60 seconds.

## Contributing

See CONTRIBUTING.md for details of how to participate in development of the module.

#### Running the sample app and unit tests

- Clone or fork the repo
- Run `bundle exec pod install` in the repo root folder
- Open `RRemoteConfig.xcworkspace` in Xcode
- Select the `SampleApp` scheme then build/run
- To run the tests press key shortcut command-U

## Changelog

See CHANGELOG.md for the new features, changes and bug fixes of the module versions.
