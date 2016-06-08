# ELHybridWeb 

[![Version](https://img.shields.io/badge/version-v3.0.0-blue.svg)](https://github.com/Electrode-iOS/ELHybridWeb/releases/latest)
[![Build Status](https://travis-ci.org/Electrode-iOS/ELHybridWeb.svg)](https://travis-ci.org/Electrode-iOS/ELHybridWeb)

ELHybridWeb is a Swift framework that provides a bridged JavaScript API and web view controller for building hybrid web applications on iOS. ELHybridWeb uses [ELJSBridge](https://github.com/Electrode-iOS/ELJSBridge) to bridge Swift objects to JavaScript.

## Installation

### Manual

Install manually by adding ELHybridWeb.xcodeproj to your project and configuring your target to link ELHybridWeb.framework.

ELHybridWeb depends on the following [Electrode-iOS](https://github.com/Electrode-iOS/) frameworks:

- [`ELJSBridge`](https://github.com/Electrode-iOS/ELJSBridge).
  - [`ELFoundation`](https://github.com/Electrode-iOS/ELFoundation).
  - [`ELLog`](https://github.com/Electrode-iOS/ELLog).

[Electrode-iOS](https://github.com/Electrode-iOS/) frameworks are designed to live side-by-side in the file system, like so:

* \MyProject
* \MyProject\ELHybridWeb
* \MyProject\ELJSBridge
* \MyProject\ELFoundation
* \MyProject\ELLog

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "Electrode-iOS/ELHybridWeb" ~> 2.0.0
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

## Contributions

We appreciate your contributions to all of our projects and look forward to interacting with you via Pull Requests, the issue tracker, via Twitter, etc.  We're happy to help you, and to have you help us.  We'll strive to answer every PR and issue and be very transparent in what we do.

When contributing code, please refer to our style guide [Dennis](https://github.com/Electrode-iOS/Dennis).

## License

The MIT License (MIT)

Copyright (c) 2015 Walmart

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
