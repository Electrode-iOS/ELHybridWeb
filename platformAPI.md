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
  - `device` (string) - The device hardware. eg: iPhone 6, Samsung Galaxy s6.
  - `platform` (string) - The device operating system and version. eg: iOS 8, Android 5.0.
  - `appVersion` (string) -  The version string that identifies the walmart app being used.


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

**Parameters**

- (object) - Optional options object.
  - `tabBarHidden` (boolean) - Determines whether the page we're animating to, shows or hides the tab bar in iOS. If this option is not provided, the default behavior in iOS would be to show the tab bar. This option is not applicable to Android, and will be ignored.
  - `title` (string) - Header title text to show on the view that is being animated to.

**Example**

Trigger a simple animate forward transition.

```
NativeBridge.navigation.animateForward();

```

Trigger an animate forward transition that hides the tab bar.

```
NativeBridge.navigation.animateForward({tabBarHidden: true});

```

Trigger an animate forward transition sets the title of the new view.

```
NativeBridge.navigation.animateForward({
  title: "Title text",
  tabBarHidden: false
});

```

#### animateBackward()

Trigger a native pop navigation transition. By default it pops a view controller off of the web view controller's navigation stack. Does not affect web view history.

**Example**

```
NativeBridge.navigation.animateBackward();

```

#### popToRoot()

Pops the native navigation stack all the way back to the root view. This will trigger the root views onAppear callback with the appropriate arguments.

**Example**

```
NativeBridge.navigation.popToRoot();

```

#### presentModal()

Trigger a native modal transition. By default the method presents a new web view controller with the current web view state. Does not affect web view history.

**Parameters**

- (object) - Optional options object.
  - `tabBarHidden` (boolean) - Determines whether the modal being presented, shows or hides the tab bar in iOS. If this option is not provided, the default behavior in iOS would be to show the tab bar. This option is not applicable to Android, and will be ignored.
  - `title` (string) - Header title text to show on the view that is being animated to.
  - `navigationBarButtons` (array) - Array of navigation bar button objects to be set. The first item in the array sets the `leftBarButtonItem` and the second item sets the `rightBarButtonItem`. If this option is not passed, the default native `back` button is displayed.
    - `title` (string) - Title text of button.
    - `id` (string) -  Unique identifier of button.
  - onNavigationBarButtonTap (function) - Callback to be triggered when `navigationBarButtons` are clicked. It will receive an argument with the `id` of the button clicked.
  - onAppear (function) - Callback to be triggered once the animation is completed and new view is ready.


**Example**

Trigger a simple present modal transition.

```
NativeBridge.navigation.presentModal();

```

Present a modal and set the title of the new view.

```
NativeBridge.navigation.presentModal({
  title: "Title text",
});

```

#### dismissModal()

Close the existing native modal view. Does not affect web view history.

**Example**

```
NativeBridge.navigation.dismissModal();

```

#### setOnBack()

Set a function callback to call when the native back button is tapped. If the native back button is tapped and the callback is not set the bridge will fallback to going back one item in web history (calling `goBack()` on the web view).

**Example**

```
NativeBridge.navigation.setOnBack(function () {
  // update page state based on back button tap
});

```

## NativeBridge.tabBar Object ##

#### show()

Shows the native iOS tab bar. This feature is not applicable to Android and will be ignored.

**Example**

```
NativeBridge.tabBar.show();

```

#### hide()

Hides the native iOS tab bar. This feature is not applicable to Android and will be ignored.

**Example**

```
NativeBridge.tabBar.hide();

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

## NativeBridge.view Object ##

#### show()

Shows the current web view. This allows to webapp to indicate to the native app thats its ready to be shown.

**Example**

```
NativeBridge.view.show();

```

#### setOnAppear()

Sets a callback on the current web view that will be triggered when it becomes visible to the user. This callback will be triggered in one of three cases:
- When a user navigates from elsewhere in the native app back to the view that sets this callback.
- When the view appears as a result of a native `animateBackward` transition.
- When the view appears as a results of a native `popToRoot` transition.

**Parameters**

- (function) - Callback to be triggered.

**Example**

```
NativeBridge.view.setOnAppear(function () {
  // Do something
});

```

#### setOnDisappear()

Sets a callback on the current web view that will be triggered when this view is about to be transitioned out of.

**Example**

```
NativeBridge.view.setOnDisappear(function () {
  // Do something
});

```
