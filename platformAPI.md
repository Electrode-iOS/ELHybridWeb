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

#### newState()

Creates a new `NativeBridge` object and adds it to the existing view and JavaScript context.

**Example**

```
NativeBridge.newState();

```

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

Present an alert view.

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

Trigger a native push navigation transition. Pushes a new web view controller on to the web view controller's navigation stack with the existing web view. `animateForward` hides the web view in order to allow the web app to show the view when it has completed loading its state. The web view will remain hidden until `view.show()` is called. This method does not affect web view history.

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

Pops the visible web view controller off of the web view controller's navigation stack. `animateBackward` hides the web view in order to allow the web app to show the view when it has completed loading its state. The web view will remain hidden until `view.show()` is called.  Does not affect web view history.

**Example**

```
NativeBridge.navigation.animateBackward();

```

#### popToRoot()

Pops the native navigation stack all the way back to the root view. This will trigger the root view's `onAppear` callback.

**Example**

```
NativeBridge.navigation.popToRoot();

```

#### presentModal()

Trigger a native modal transition. 

Presents a new web view controller as a modal transition using the existing web view state. `presentModal` hides the web view in order to allow the web app to show the view when it has completed loading its state. The web view will remain hidden until `view.show()` is called. Does not affect web view history.

**Parameters**

- (object) - Optional options object.
  - `tabBarHidden` (boolean) - Determines whether the modal being presented, shows or hides the tab bar in iOS. If this option is not provided, the default behavior in iOS would be to show the tab bar. This option is not applicable to Android, and will be ignored.
  - `title` (string) - Header title text to show on the view that is being animated to.
  - `navigationBarButtons` (array) - Array of navigation bar button objects to be set. The first item in the array sets the `leftBarButtonItem` and the second item sets the `rightBarButtonItem`. If this option is not passed, the default native `back` button is displayed.
    - `title` (string) - Title text of button.
    - `id` (string) -  Unique identifier of button.
  - `onNavigationBarButtonTap` (function) - Callback to be triggered when `navigationBarButtons` are clicked. It will receive an argument with the `id` of the button clicked.
  - `onAppear` (function) - Callback to be triggered once the animation is completed and new view is ready.


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

Present a modal with navigation bar buttons.

```
NativeBridge.navigation.presentModal({
  title: "Modal View Title",
  navigationBarButtons: [{
    title: "Cancel",
    id: "cancel"
  }, {
    title: "Done",
    id: "done"
  }],
  onNavigationBarButtonTap: function(id) {
    NativeBridge.navigation.dismissModal();
  }
});
```

Present a modal with only a right navigation bar button.

```
NativeBridge.navigation.presentModal({
  title: "Modal View Title",
  navigationBarButtons: [null, {
    title: "Done",
    id: "done"
  }],
  onNavigationBarButtonTap: function(id) {
    NativeBridge.navigation.dismissModal();
  }
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

#### presentExternalURL()
 
Present a new web view modally and the load the provided URL. Adds a custom back button that when tapped, checks web view history to determine if the web view should be dismissed or if history.back() should be called. If the external web view is at the beginning of its page history the modal is dismissed, displaying the original page that presented the external web view.

The external web view modal contains "Back" left navigation bar button and a "Done" right navigation bar button. The Back button goes back in web history on each tap. If the external web view history is at the beginning the modal web view will be dismissed.

The Done button dismisses the external web view regardless of the web history.


**Parameters**

- (object) - Options object.
  - `url` (string) - External URL to load into the new modal web view.
  - `returnURL` (string) - URL that the external web view should intercept and load into the original web view that had presented the external web view. The external web view modal will be dismissed and the URL will not be loaded in the external web view. The the intercepted URL can match any part of the return URL. For example the returnURL value of `"www.walmart.com"` will intercept any URL that contains the host `www.walmart.com`.
  - `title` (string) - Title text for the navigation bar of the external web view.

**Example**

```
var options = {
  url: "http://www.apple.com/", 
  returnURL: "www.walmart.com"
};
NativeBridge.navigation.presentExternalURL(options);

```

#### dismissExternalURL()

Dismiss the external web view and load the provided URL into the previous web view that had presented the external URL.

**Parameters**

- `url` (string) - URL to load into the original web view that had presented the external web view. The URL to return to.

**Example**

```
NativeBridge.navigation.dismissExternalURL("http://www.walmart.com/");

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

Two navigation bar buttons can be set, left and right. Adding a "Cancel" left navigation bar button and a "Done" right navigation bar button:

```
var buttons = [{
  title: "Cancel",
  id: "cancel"
}, {
  title: "Done",
  id: "done"
}];

NativeBridge.navigationBar.setButtons(buttons, function (buttonID) {
  // handle button tap
});
```

Remove navigation bar buttons by passing `null` or an empty array as the first parameter to `setButtons()`.

```
window.NativeBridge.navigationBar.setButtons(null);
```

`null` can also be used to add only a right or left navigation bar button. With `null` as the first value in the array only a right navigation bar button is added.

```
var buttons = [null, {
  title: "Done",
  id: "done"
}];

NativeBridge.navigationBar.setButtons(buttons, function (buttonID) {
  // handle button tap
});
```


## NativeBridge.view Object ##

#### show()

Shows the current web view. This allows to web app to indicate to the native app thats its ready to be shown.

**Example**

```
NativeBridge.view.show();

```

#### setOnAppear()

Sets a callback on the current web view that will be triggered when it becomes visible to the user. For iOS developers this is the equivalent of `UIViewController`'s `viewWillAppear(animated:)` method.

The callback is triggered anytime a view appears on screen which means it is called as a result of `animateForward`, `animateBackward`, `presentModal`, `dismissModal` and  `popToRoot` calls. All of these methods cause an animation transition to occur with a new or previous view appearing on screen. This method is also called when a view appears as a result of switching tabs in a tab bar controller.

**Parameters**

- (function) - Callback to be triggered.

**Example**

```
NativeBridge.view.setOnAppear(function () {
  // Do something
});

```

#### setOnDisappear()

Sets a callback on the current web view that will be triggered when this view is about to be transitioned out of. For iOS developers this is the equivalent of `UIViewController`'s `viewWillDisappear(animated:)` method.

The callback is triggered anytime a view disappears from screen which means it is called as a result of `animateForward`, `animateBackward`, `presentModal`, `dismissModal` and  `popToRoot` calls. All of these methods cause an animation transition to occur with a new or previous view appearing on screen. This method is also called when a view disappears as a result of switching tabs in a tab bar controller.


**Example**

```
NativeBridge.view.setOnDisappear(function () {
  // Do something
});

```
