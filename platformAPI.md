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

## NativeBridge.navigationBar ##

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
