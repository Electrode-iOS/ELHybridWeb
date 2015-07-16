Platform API documentation
==========================

## Global API functions ##

#### nativeBridgeReady()

An optional callback to invoke after the web view has finished loading and the bridge APIs are ready for use. Note,
this function is called *from* the Native application and is not bound to the NativeBridge object.

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

## NativeBridge Object ##

#### info()

Provides information that identifies the device and platform.

**Returns**

- `(object)`  - Object containing the device and platform info.
  - `device` (string) - The hardware being user. eg: iphone 6, samsung galaxy s6.
  - `platform` (string) - The device operating system and version. eg: iOs 8, android 5.0
  - `appVersion` (string) -  The version string that identifies the walmart app being used


**Example**

```
NativeBridge.info();

```

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

## NativeBridge.navigation Object ##

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

#### presentModal()

Trigger a native modal transition. By default the method presents a new web view controller with the current web view state. Does not affect web view history.

**Example**

```
NativeBridge.navigation.presentModal();

```

#### dismissModal()

Close the existing native modal view. Does not affect web view history.

**Example**

```
NativeBridge.navigation.dismissModal();

```


## NativeBridge.navigationBar Object ##

#### setTitle()

Set the title text of the navigation bar.

**Parameters**

- `title` (string) -  Title text.

**Example**

```
NativeBridge.navigationBar.setTitle("Item Details");

```

#### setButtons()

Set the navigation bar's buttons with an array of button objects.

**Parameters**

- `buttons` (array) - Array of navigation bar button objects to set. The first item in the array sets the `leftBarButtonItem` and the second item sets the `rightBarButtonItem`.
  - `title` (string) - Title text of button.
  - `id` (string) -  Unique identifier of button.
  - `image` (string) -  Optional image asset name to load.

**Example**

```
var buttons = [{
  title: "Cancel",
  id: "cancel"
}, {
  title: "Done",
  id: "done"
}];

window.NativeBridge.navigationBar.setButtons(buttons, function (buttonID) {
  // handle button tap
});
```

Remove navigation bar buttons by passing `null` or an empty array as the first parameter to `setButtons()`.

```
window.NativeBridge.navigationBar.setButtons(null);
```
