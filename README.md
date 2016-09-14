# ELHybridWeb 

[![Version](https://img.shields.io/badge/version-v3.1.0-blue.svg)](https://github.com/Electrode-iOS/ELHybridWeb/releases/latest)
[![Build Status](https://travis-ci.org/Electrode-iOS/ELHybridWeb.svg?branch=master)](https://travis-ci.org/Electrode-iOS/ELHybridWeb)

ELHybridWeb is a Swift framework that provides a bridged JavaScript API and web view controller for building hybrid web applications on iOS. ELHybridWeb uses [ELJSBridge](https://github.com/Electrode-iOS/ELJSBridge) to bridge Swift objects to JavaScript.

## Requirements

ELHybridWeb requires Swift 2.3, Xcode 8, and depends on the following [Electrode-iOS](https://github.com/Electrode-iOS/) frameworks:

- [`ELJSBridge`](https://github.com/Electrode-iOS/ELJSBridge).
- [`ELFoundation`](https://github.com/Electrode-iOS/ELFoundation).
- [`ELLog`](https://github.com/Electrode-iOS/ELLog).

[Electrode-iOS](https://github.com/Electrode-iOS/) frameworks are designed to live side-by-side in the file system, like so:

* \MyProject
* \MyProject\ELHybridWeb
* \MyProject\ELJSBridge
* \MyProject\ELFoundation
* \MyProject\ELLog

## Installation

### Manual

Install manually by adding ELHybridWeb.xcodeproj to your project and configuring your target to link ELHybridWeb.framework.

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "Electrode-iOS/ELHybridWeb" ~> 3.1.0
```

## Usage

### iOS

Initialize a web view controller and call `loadURL()` to asynchronously load the web view with a URL. 

```
let webController = WebViewController()
webController.loadURL(NSURL(string: "foo")!)
window?.rootViewController = webController
```

To utilize the navigation JavaScript API you must provide a navigation controller for the web view controller.

```
let webController = WebViewController()
webController.addHybridAPI()
webController.loadURL(NSURL(string: "foo")!)

let navigationController = UINavigationController(rootViewController: webController)
window?.rootViewController = navigationController
```

### Web

See the [Platform API documentation](platformAPI.md) for a reference of the JavaScript API. An example web application is available at [http://bridgeofdeath.herokuapp.com/](http://bridgeofdeath.herokuapp.com/) that demonstrates basic web usage of ELHybridWeb.

## Example

A test iOS project is located in Example/ELHybridWebExample.xcodeproj that is configured to load the test page at [http://bridgeofdeath.herokuapp.com/](http://bridgeofdeath.herokuapp.com/).
