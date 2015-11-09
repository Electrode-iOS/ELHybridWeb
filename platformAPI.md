Platform API documentation
==========================

The platform API is a JavaScript API that provides a bridge to native device APIs for iOS and Android. [Zoot](https://github.com/TheHolyGrail/Zoot) is the implementation for iOS that bridges the platform API to native Objective-C-based APIs. Her twin, [Dingo](https://github.com/TheHolyGrail/Dingo), is a Java framework that bridges the API to native Android APIs. 

The platform API enables web applications to use native device APIs for building hybrid experiences.

### Terminology

- **"bridge"** - The native code that exposes a JavaScript API as a `NativeBridge` object and provides a web view for the hybrid web application
- **"`NativeBridge` object"** - the JavaScript object that encapsulates the platform API
- **"web view"** - On iOS this is the `UIWebView` instance that is responsible for loading and rendering the hybrid web application's content. The same instance is reused throughout all native navigation transitions. Any time the bridge animates forward/backward or presents/dismisses a modal it is moving the same web view instance between native views.
- **"native view"** - the native view(`UIView`) that contains the web view. The term is used to describe the separate views that animate on and off screen when calling navigation API methods like `animateForward()`, `animateBackward()`, `popToRoot()`, `presentModal()`, and `dismissModal()`.
- **"hybrid web application"** - The web application that is being loaded into the web view
- **"native navigation stack"** - The stack of native views that is pushed to and popped from when making `animateForward()` and `animateBackward()` calls.


## Global Functions ##

#### nativeBridgeReady()

An optional callback function to invoke after the web view has finished loading and the bridge APIs are ready for use. Note,
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

The `NativeBridge` object is the JavaScript object that encapsulates the platform API.

#### Lifecycle

The `NativeBridge` object is added to the JavaScript context as soon as the context is created by the web view. Typically this means that the `NativeBridge` will already have been created by the time the hybrid web application's scripts are loaded allowing the scripts to access the API. For the cases that the `NativeBridge` object is `undefined` when the hybrid web app's scripts run, the `nativeBridgeReady()` callback should be set so that the web app can be notified that the `NativeBridge` object has been initialized.

A new `NativeBridge` object is initialized when the hybrid web application transitions to a new native view as a result of `animateForward()` and `presentModal()` calls. This enables the hybrid web application to configure the `NativeBridge` object relative to the native view that is containing the web app. For example this allows callbacks such as `onAppear`, `onDisappear`, and `onBack` to be configured differently for each native view.

The `NativeBridge` object instances are persisted in each native view. This means that when you `animateBackward()` or `dismissModal()` back to a previous native view, any callbacks set on the previous view will remain intact.


### newState()

Creates a new `NativeBridge` object and adds it to the existing view and JavaScript context.

**Example**

```
NativeBridge.newState();

```

### info()

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

### share()

Present an activity view controller with `message` and `url` as the activity items.

**Usage**

The web application uses the `share()` method to enable the user to share content via social media or e-mail. In iOS this method presents the system default activity view controller.

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

### dialog()

Present an alert view.

**Usage**

Enables the hybrid web application to display a native alert view (`UIAlertView`) with a message and buttons. Each dialog action represents a button. When a button is tapped the `callback` function will be called with the action ID allowing the hybrid web application to handle the button tap.

Note: Since dialogs can be cancelled on Android, the action ID `back` will be returned if the dialog is cancelled, eg. by pressing the back button. This is not applicable for iOS.

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

The native navigation API enables web apps to push and pop native views on and off of the native navigation stack via `animateForward()` and `animateBackward()` calls. Calls to these methods do not afffect web history state which allows the web application to have complete control over loading the page's state.

### animateForward()

Pushes a new native view on to the native navigation stack while reusing the existing web view. `animateForward` hides the web view in order to allow the web app to show the web view when it has completed loading its state. The web view will remain hidden until `view.show()` is called. This method does not affect web view history.

**Usage**

The hybrid web application should use `animateForward()` to add a new native view to the native navigation stack. Typically `animateForward()` will be called anytime the web application is loading a new page and wants to indicate a change in page state by animating forward with native navigation. This allows the user to navigate backward to the previous view using the default back button on navigation bar(`UINavigationBar`).

By default when the user taps the back button the web view will go back in web history one item (`history.back()`) and pop the view off of the navigation stack. This reuslts in animating backward to the previous view with the previous page in web history loaded into the web view. However, if `navigation.onBack` has a valid function callback the `onBack` handler will be called instead of `history.back()` in the web view.

**Parameters**

- (object) - Optional options object.
  - `tabBarHidden` (boolean) - Determines whether the page we're animating to, shows or hides the tab bar in iOS. If this option is not provided, the default behavior in iOS would be to show the tab bar. This option is not applicable to Android, and will be ignored.
  - `title` (string) - Header title text to show on the view that is being animated to.
  - `onWillAppear` (function) - Callback that will be run before the view appears on screen as a result of the animation. The callback runs before `onAppear`.

**Example**

Perform a simple animate forward transition.

```
NativeBridge.navigation.animateForward();

```

Perform a forward animation transition and hide the tab bar.

```
NativeBridge.navigation.animateForward({tabBarHidden: true});

```

Perform a forward animation transition and set the title of the new view.

```
// indicate to the native bridge to animate forward to a new view
NativeBridge.navigation.animateForward({
  title: "Page Two",
  tabBarHidden: false
});

// load new page state
window.location.href = "/pageTwo"
```

Perform a forward animation transition with an `onWillAppear` callback.

```
NativeBridge.navigation.animateForward({
  title: "Page Two",
  tabBarHidden: false,
  onWillAppear: function () {
    NativeBridge.view.show();
  }
});
```

### animateBackward()

Pops the visible native view off of the native navigation stack. `animateBackward()` hides the web view in order to allow the web app to show the view when it has completed loading its state. The web view will remain hidden until `view.show()` is called.  Does not affect web view history.

**Usage**

The hybrid web application uses `animateBackward()` to pop the current view off of the navigation stack and return to the previous view. This method will not modify web history like the navigation bar's back button will. The hybrid web application is required to load the state that represents the previous view.

**Example**

```
NativeBridge.navigation.animateBackward();

```

### popToRoot()

Pops the native navigation stack all the way back to the root view. This will trigger the root view's `onAppear` callback.

**Usage**

The hybrid web application uses `popToRoot()` to pop all native views off of the native navigation stack. It can be thought of as an `animateBackward()` that instead removes every view off of the stack instead of only popping the current visible native view.

**Example**

```
NativeBridge.navigation.popToRoot();

```

### presentModal()

Presents a new native modal view containing the web view. `presentModal()` hides the web view in order to allow the hybrid web app to show the view when it has completed loading its state. The web view will remain hidden until `view.show()` is called. The modal native view will be presented over top of the native view that presents it and will remain on screen until `dismissModal()` is called. This method does not modify web history.

**Usage**

The hybrid web application uses `presentModal()` to present content modally. Typically the hybrid web application will modify the DOM instead of loading a new page when preparing the content to display in the modal view.

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

### dismissModal()

Closes the visible modal view that was presented by a `presentModal()` call, returning the user to the original presenting view. This method does not modify web view history.

**Usage**

The hybrid web application uses `dismissModal()` to dismiss a modal that the application had previously presented.

**Example**

```
NativeBridge.navigation.dismissModal();

```

### setOnBack()

Set a function callback to call when the native back button is tapped. If the native back button is tapped and the callback is not set the bridge will fallback to going back one item in web history (calling `goBack()` on the web view).

**Example**

```
NativeBridge.navigation.setOnBack(function () {
  // update page state based on back button tap
});

```

### presentExternalURL()
 
Present a new web view modally and the load the provided URL. Adds a custom back button that when tapped, checks web view history to determine if the web view should be dismissed or if history.back() should be called. If the external web view is at the beginning of its page history the modal is dismissed, displaying the original page that presented the external web view.

The external web view modal contains "Back" left navigation bar button and a "Done" right navigation bar button. The Back button goes back in web history on each tap. If the external web view history is at the beginning the modal web view will be dismissed.

The Done button dismisses the external web view regardless of the web history.

**Usage**

The `presentExternalURL()` method can be used when the hybrid web application needs to navigate to an external web application or website that the hybrid web app developer does not control. It allows the user to freely navigate forward and backward in a new web view instance without modfiying the web history of the hybrid web application.

An optional `returnURL` option can be set that enables the hybrid web application to intercept a request of the external web view in order to return to the original hybrid web application's web view. When the external web view attempts to load a request the request's URL will be compared against the `returnURL` value to determine if the request should be intercepted. Ignoring the query string value, the `returnURL` will match against any subset of the intercepted URL including the scheme, domain, port, and path. For example the `returnURL` value of `"https//github.com/TheHolyGrail"` will intercept the URLs `"https//github.com/TheHolyGrail/Zoot"` and `"https//github.com/TheHolyGrail/BridgeOfDeath"` but not the URL `"https//github.com/"`.

After a request has been matched against the `returnURL` value the bridge prevents the request from loading inside the external web view and instead loads it into the original hybrid web application's web view. The external web view is dismissed and the user returns to the original web application's web view with the intercepted request loaded into it.

**Parameters**

- (object) - Options object.
  - `url` (string) - External URL to load into the new modal web view.
  - `returnURL` (string) - A subset of the URL to be intercepted in order to return to the presenting web view.
  - `title` (string) - Title text for the navigation bar of the external web view.

**Example**

```
var options = {
  url: "http://www.walmart.com/", 
  returnURL: "https//github.com/TheHolyGrail"
};
NativeBridge.navigation.presentExternalURL(options);
```

### dismissExternalURL()

Dismiss the external web view and load the provided URL into the previous web view that had presented the external URL.

**Parameters**

- `url` (string) - URL to load into the original web view that had presented the external web view. The URL to return to.

**Example**

```
NativeBridge.navigation.dismissExternalURL("http://www.walmart.com/");

```


## NativeBridge.tabBar Object ##

### show()

Shows the native iOS tab bar. This feature is not applicable to Android and will be ignored.

**Example**

```
NativeBridge.tabBar.show();

```

### hide()

Hides the native iOS tab bar. This feature is not applicable to Android and will be ignored.

**Example**

```
NativeBridge.tabBar.hide();

```


## NativeBridge.navigationBar Object ##

### setTitle()

Set the title text of the navigation bar.

**Parameters**

- `title` (string) -  Title text.

**Example**

```
NativeBridge.navigationBar.setTitle("Item Details");

```

### setButtons()

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

### show()

Shows the web view that was previously hidden. 

**Usage**

This enables the hybrid web app to indicate that it has completed loading and is ready to show the web view. The web view is hidden as a result of `animateForward(), `animateBackward()`, `presentModal()` and `dismissModal()` calls. Because the bridge resuses the same web view it is hidden and shown between native navigation transitions in order to appear as if it is a new web view.

**Example**

```
NativeBridge.view.show();

```

### setOnAppear()

Sets a callback on the current native view that will be called when the native view becomes visible to the user. For iOS developers this is the equivalent of `UIViewController`'s `viewWillAppear(animated:)` method.

The callback is triggered anytime a native view appears on screen which means it is called as a result of `animateForward`, `animateBackward`, `presentModal`, `dismissModal` and  `popToRoot` calls. All of these methods cause an animation transition to occur with a new or previous native view appearing on screen. This method is also called when a native view appears as a result of switching tabs in a tab bar controller.

**Usage** 

The hybrid web application uses the callback to know when the native view has appeared on screen. 

**Parameters**

- (function) - Callback to be triggered.

**Example**

```
NativeBridge.view.setOnAppear(function () {
  // Do something
});

```

### setOnDisappear()

Sets a callback on the current native view that will be called when the native view is transitions off of the screen. For iOS developers this is the equivalent of `UIViewController`'s `viewWillDisappear(animated:)` method.

The callback is triggered anytime a view disappears from screen which means it is called as a result of `animateForward`, `animateBackward`, `presentModal`, `dismissModal` and  `popToRoot` calls. All of these methods cause an animation transition to occur with a new or previous view appearing on screen. This method is also called when a view disappears as a result of switching tabs in a tab bar controller.

**Usage** 

The hybrid web application uses the callback to know when the native view has disappeared from the screen. 

**Example**

```
NativeBridge.view.setOnDisappear(function () {
  // Do something
});

```
