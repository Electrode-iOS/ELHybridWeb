# Zoot

Zoot (`THGHybridWeb` module) is a Swift framework that provides a bridged JavaScript API and web view controller for building hybrid web applications on iOS. Zoot uses [BridgeOfDeath](https://github.com/TheHolyGrail/BridgeOfDeath) to bridge Swift objects to JavaScript.

## Installation

### Carthage

Install with [Carthage](https://github.com/Carthage/Carthage) by adding the framework to your project's [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

```
github "TheHolyGrail/Zoot" ~> 0.0.2
```

### Manual

Install manually by adding THGHybridWeb.xcodeproj to your project and configuring your target to link THGHybridWeb.framework.

Zoot depends on the following [THG](https://github.com/TheHolyGrail/) modules:

- [`THGBridge`/BridgeOfDeath](https://github.com/TheHolyGrail/BridgeOfDeath).
  - [`THGFoundation`/Excalibur](https://github.com/TheHolyGrail/Excalibur).
  - [`THGLog`/Shrubbery](https://github.com/TheHolyGrail/Shrubbery).

[THG](https://github.com/TheHolyGrail/) modules are designed to live side-by-side in the file system, like so:

* \MyProject
* \MyProject\Zoot
* \MyProject\BridgeOfDeath
* \MyProject\Excalibur
* \MyProject\Shrubbery

## Usage

## JavaScript API Reference

#### nativeBridgeReady()

An optional callback to invoke after the web view has finished loading and the bridge APIs are ready for use.

**Parameters**

- `error` (object) - Error
- `bridge` (object) - The native bridge API object.

**Example**

```
// wait for the bridge to be ready

function bridgeReady() {
  // web view is loaded and bridge is ready for use
}

if (window.NativeBridge === undefined) {
  window.nativeBridgeReady = function(error, bridge) {
    bridgeReady();
  }
} else {
  bridgeReady();
}
```

### NativeBridge

#### share()

Present an activity view controller with `message` and `url` as the activity items.

**Parameters**

- `options` (object) - Options
  - `message` (string) - Message text to share.
  - `url` (string) -  URL to share.

**Example**

```
var options = {
  message: "What is your quest?", 
  url: "https://github.com/TheHolyGrail/BridgeOfDeath"
};

NativeBridge.share(options);

```

#### dialog()

Present an activity view controller with `message` and `url` as the activity items.

**Parameters**

- `options` (object) - Options
  - `title` (string) -  Title text.
  - `message` (string) - Message text.
  - `actions` (array) - Array of dialog actions.
    - `id` (string) - Action identifier
    - `label` (string) - Action label text.
- `callback` (function(error, id)) - Callback to invoke when dialog action is tapped.
  - `error - Possible error.
  - `id` - ID of action that was tapped.

**Example**

```
var options = {
  title: "Title of Dialog",
  message: "Message of Dialog",
  actions: [{
    id: "cancel",
    label: "Cancel"
  }, {
    id: "ok",
    label: "Ok"
  }]
};

window.NativeBridge.dialog(options, function(error, id) {
  // handle action
});

```

### NativeBridge.navigationBar

#### setTitle()

Set the title text of the navigation bar.

**Parameters**

- `title` (string) -  Title text.

**Example**

```
NativeBridge.navigationBar.setTitle("Item Details");

```

#### createButton()

Create a navigation bar button object.

**Parameters**

- `title` (string) - Title text of button.
- `onClick` (function) - Function to call when button is tapped.

**Example**

```
var cancelButton = NativeBridge.navigationBar.createButton("Cancel", function () {
   // handle cancel button tap
});

```

#### setButtons()

Set the navigation bar's buttons with an array of button objects.

**Parameters**

- `buttons` (array) - Array of navigation bar button objects to set. The first item in the array sets the `leftBarButtonItem` and the second item sets the `rightBarButtonItem`.

**Example**

```
var cancelButton = NativeBridge.navigationBar.createButton("Cancel", function () {
   // handle cancel button tap
});

var doneButton = NativeBridge.navigationBar.createButton("Done", function () {
  // handle done button tap
});


NativeBridge.navigationBar.setButtons([cancelButton, doneButton]);

```

### NativeBridge.navigation

#### animateForward()

Trigger a native push navigation transition. By default it pushes a new web view controller on to the web view controller's navigation stack with the current web view. Does not affect web view history.

**Example**

```
NativeBridge.navigation.animateForward();

```

#### animateBackward()

Trigger a native pop navigation transition. By default it pops a view controller off of the web view controller's navigation stack. Does not affect web view history.

**Example**

```
NativeBridge.navigation.animateBackward();

```

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
