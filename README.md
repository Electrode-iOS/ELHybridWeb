# Zoot

Zoot (`THGHybridWeb` framework) is a Swift framework that provides a bridged JavaScript API and web view controller for building hybrid web applications on iOS. Zoot uses [BridgeOfDeath](https://github.com/TheHolyGrail/BridgeOfDeath) to bridge Swift objects to JavaScript.

## Installation

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "TheHolyGrail/Zoot" ~> 0.1.0
```

### Manual

Install manually by adding THGHybridWeb.xcodeproj to your project and configuring your target to link THGHybridWeb.framework.

Zoot depends on the following [THG](https://github.com/TheHolyGrail/) frameworks:

- [`THGBridge`/BridgeOfDeath](https://github.com/TheHolyGrail/BridgeOfDeath).
  - [`THGFoundation`/Excalibur](https://github.com/TheHolyGrail/Excalibur).
  - [`THGLog`/Shrubbery](https://github.com/TheHolyGrail/Shrubbery).

[THG](https://github.com/TheHolyGrail/) frameworks are designed to live side-by-side in the file system, like so:

* \MyProject
* \MyProject\Zoot
* \MyProject\BridgeOfDeath
* \MyProject\Excalibur
* \MyProject\Shrubbery

## Usage

Initialize a web view controller and call `loadURL()` to asynchronously load the web view with a URL. 

```
let webController = WebViewController()
webController.loadURL(NSURL(string: "foo")!)
window?.rootViewController = webController
```

Call `addHybridAPI()` to add the bridged JavaScript API to the web view. The JavaScript API will be accessible to any web pages that are loaded in the web view controller.

```
let webController = WebViewController()
webController.addHybridAPI()
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

[See the Platform API documentation](platformAPI.md)

## Example

A test iOS project is located in Example/ZootExample.xcodeproj that is configured to load the test page at [http://bridgeofdeath.herokuapp.com/](http://bridgeofdeath.herokuapp.com/).

## Contributions

We appreciate your contributions to all of our projects and look forward to interacting with you via Pull Requests, the issue tracker, via Twitter, etc.  We're happy to help you, and to have you help us.  We'll strive to answer every PR and issue and be very transparent in what we do.

When contributing code, please refer to our style guide [Dennis](https://github.com/TheHolyGrail/Dennis).

###### THG's Primary Contributors

Dr. Sneed ([@bsneed](https://github.com/bsneed))<br>
Steve Riggins ([@steveriggins](https://github.com/steveriggins))<br>
Sam Grover ([@samgrover](https://github.com/samgrover))<br>
Angelo Di Paolo ([@angelodipaolo](https://github.com/angelodipaolo))<br>
Cody Garvin ([@migs647](https://github.com/migs647))<br>
Wes Ostler ([@wesostler](https://github.com/wesostler))<br>

## License

The MIT License (MIT)

Copyright (c) 2015 Walmart, TheHolyGrail, and other Contributors

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
