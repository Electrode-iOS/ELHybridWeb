# [5.2.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v5.2.0)

- Remove ELLog dependency

# [5.1.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v5.1.0)

- Add a target that builds a static framework for iOS platform.

# [5.0.2](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v5.0.2)

- Update to Xcode 9.3 recommended project settings
- Fix Xcode 9.3 warnings

# [5.0.1](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v5.0.1)

- Expose `didCreateJavaScriptContext` to Obj-C. Fixes an issue in Swift 4 that was preventing didCreateJavaScriptContext from being called which resulted in the JS API never being added to the web view's JS context.

# [5.0.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v5.0.0)

- Migrate to Swift 4

# [4.0.8](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.8)

- Use `overCurrentContext` presentation style when presenting modal views

# [4.0.7](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.7)

- Use safe area layout guide for web view

# [4.0.6](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.6)

- Use default settings for bitcode

# [4.0.5](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.5)

- Make JSValue helpers public.

# [4.0.4](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.4)

- Update all hybrid APIs to export to JS properly after Swift 3 migration mistakenly converted the APIs to be wrongly exported

# [4.0.3](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.3)

- Update `didCreateJavaScriptContext` signature to work with Swift 3. Fixes an issue that was preventing the Hybrid API object from being injected into the `JSContext`.

# [4.0.2](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.2)

- Fixed failing unit tests that started failing after migrating to Swift 3

# [4.0.1](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.1)

- Make `sharedLogger` API public

# [4.0.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v4.0.0)

- Migrated to Swift 3
- Simplify logging code by removing unnecessary ELHybridWeb class
- Removed dead logging code
- Removed ELJSBridge as a dependency
- Enable dependencies to be installed via Carthage

# [3.1.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v3.1.0)

- Added support for Xcode 8, Swift 2.3, and iOS SDK 10

# [3.0.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v3.0.0)

### Breaking Changes

- Updated to be compatible with Swift 2.2.

### New Features

- Added logging API 

### Fixes

- Changed to auto-layout constraints to fix issue with modal web view being blank
- Add missing bundle identifier to project file
- Fix for `popToRoot()`


# [2.0.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v2.0.0)

- Updated to support Swift 2 and iOS SDK 9

### API Changes for Swift 2 and iOS SDK 9

- `BarButton` now explicitly inherits from `NSObject` 
- Declare all API export protocols in `HybridAPI` class declaration
- The `webViewController(webViewController: WebViewController, didFailLoadWithError error: NSError?)` method of the protocol `WebViewControllerDelegate` has been changed to pass an optional `NSError` type in order to adapt to `UIWebViewDelegate`'s `didFailLoadWithError` method now passing an optional error value.

# [1.0.3](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v1.0.3)

- track disappearance cause when popping to root to prevent web view from going back

# [1.0.2](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v1.0.2)

- Run `view.show()` on the main thread.

# [1.0.1](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v1.0.1)

- Prevent multiple alert views from displaying while an alert view is currently visible
- Keep reference to dialog API's alert view so the delegate can be set to nil. Fixes a crash on iOS 7.
- Use auto-layout to pin sides of web view

# [1.0.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v1.0.0)

- Added `WebViewManager` to propogate JS context creation events to registered web views. Fixes an issue that was causing the didCreateContext method to clash with another bridge's implementation
- Allow `NSURLSessionDelegate` to perform default handling of an auth challenge when `challengeHost` does not match
- Change to `NSURL`'s `absoluteString` method in order to support pre iOS 8
- Check for a valid options value before attempting to reference the value's properties
- Added support for server trust challenge
- Change to use `boldSystemFontOfSize()` in order to support iOS 7
- Added support for custom User Agent header
- Change to not invoke `onAppear` callback at the time the callback function is set
- Change to use `NSURLSession` to load web view request
- Change to use `safelyCallWithData()` to invoke dialog action callback
- Hide web view when displaying error UI
- Ignore the query string when matching external URLs against the `returnURL` value. Fixes #56
- Added optional`title` parameter to `presentExternalURL()`
- Moved the decision logic for intercepting external requests to `didInterceptRequest:` method
- Updated `presentExternalURL()` method to use options hash object instead of function parameters
- Added `returnURL` parameter to `presentExternalURL()` for intercepting matching requests and returning to original web view
- Added `presentExternalURL()` and `dismissExternalURL()` for transitioning to external web pages and back
- Check for `null` and `undefined` before using navigation bar buttons in web controller options
- Allow `null` to be passed as first item in nav bar buttons array to avoid setting left button
- Added `newState()` method that allows web to explicitly create a new bridge API object
- Stop loading and set web view delegate when disappearing from back button tap/pop
- Added unit tests for view and tab bar APIs
- Prevent onAppear from running after the view is popped
- Hide web view when popping as a result of navbar back press
- Publicly expose `appearedFrom` and `disappearedBy` as read only
- Added `safelyCallWithArguments` function to fix deadlocks with JS callbacks.
- Removed dispatch_async calls and switched to safelyCallWithArguments()
- Added navigation bar options and onAppear callback to presentModal
- Filtered out undefined and null values when setting onAppear and onBack callbacks of a new web view controller
- Use asValidValue to check for undefined before invoking JSValue callback
- Change to not automatically show web view when popping view controllers
- Use JSValue to strongly retain  appearance callbacks
- Added callback to presentModal/animateForward API for handling native back button
- Set appearance callbacks on main thread only when needed
- Removed dispatches here as they caused lockups.  Angelo to replace with safer method soon.
- Removed dispatch_async to main thread in hybrid view.appeared since this is always on the main thread
- Change to not set `parentViewController` reference of Hybrid APIs in `viewWillAppear:`
- Change to not affect web history when popping back in native navigation
- Added options to `animateForward()` for configuring the next view's nav bar and appear callback
- Added options to `presentModal()` for configuring the modal view's nav bar and appear callback
- Added callback `animateForward` and `presentModal` for referencing the next view's bridge API object
- Added `asValidValue` for creating an optional from and undefined or null `JSValue`
- Refactor dialog API to use `UIAlertView` for iOS 7 compatibility. Fixes #43
- Added fresh bridge API object to context after animateForward/presentModal
- Change to only call `nativeBridgeReady` callback when defined
- Added  method to allow  customization of web view requests
- Change to set and run appearance callbacks on the main thread

# [0.2.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.2.0)

- Use bridgeObject reference to call appearance APIs
- Do not set owner of managed JS value so callback is released when garbage collected
- Weakly store bridge API reference to set parent vc
- Track both appearance and disappearance states in order to configure web view properly after dismissModal/animateBackward transitions. Fixes [#39](https://github.com/Electrode-iOS/ELHybridWeb/issues/39).
- Added `didCreateJavaScriptContext` in order to add bridge scripts prior to page load
- Prevent error display on tab bar double tap

# [0.1.0](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.1.0)

- Added `tabBarHidden` option to navigation API's `animateForward()` method. Fixes [#28](https://github.com/Electrode-iOS/ELHybridWeb/issues/28).
- Added new `pushWebViewController` method with `hideBottomBar` option
- Added hide/show tab bar API. Fixes [#31](https://github.com/Electrode-iOS/ELHybridWeb/issues/31)
- Make `showWebView()` public
- Added `popToRoot()` method in navigation API. Fixes [#32](https://github.com/Electrode-iOS/ELHybridWeb/issues/32)
- Wait for view.show() bridge call to unhide web view after `animateForward()` and `presentModal()`. Fixes [#30](https://github.com/Electrode-iOS/ELHybridWeb/issues/30). You must now explicitly call `view.show()` to show the web view after a call to `navigation.animateForward()` or `navigation.presentModal()`.
- Removed delay before showing web view
- Update `WebViewController` to trigger onAppear/onDisappear JS callbacks. Fixes [#29](https://github.com/Electrode-iOS/ELHybridWeb/issues/29)
- Added `onAppear` and `onDisappear` JS callbacks to view API
- Added view API with show() method for unhiding web view

# [0.0.8](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.8)

- Added `info()` hybrid API method for getting device information.
- Added noframeworks check to add compile by source compatibility
- Added unit test for initializing `WebViewController` subclasses
- Update `WebViewController` initializer to be designated
- Added `JSValue` extension method for safely converting string values
- Pass errors back to `dialog()` callback when missing required options parameters

# [0.0.7](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.7)

- `WebViewController` now uses `dynamicType` when spawning new web view controllers instances in order to support subclassed types.
- Avoid goBack in web history when `animateBackward` is called. Fixes [#16](https://github.com/Electrode-iOS/ELHybridWeb/issues/16)
- Track the web view's first completed loading cycle. Fixes [#15](https://github.com/Electrode-iOS/ELHybridWeb/issues/15), a bug that was causing the web view to remain in a hidden state after making `presentModal()` and `animateForward()` bridge calls.

# [0.0.6](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.6)

- Default to presenting modal from tab bar controller if one exists when calling `presentModal()`

# [0.0.5](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.5)

- Avoid going back in web history after dismissing a modal view controller with `dismissModal()`. Fixes [#11](https://github.com/Electrode-iOS/ELHybridWeb/issues/11).
- Navigation bar items are removed when `null` or empty array is passed to `setButtons` from JS. Fixes [#9](https://github.com/Electrode-iOS/ELHybridWeb/issues/9).
- Propagate hybrid API's `parentViewController` change to navigation bar API. Fixes [#10](https://github.com/Electrode-iOS/ELHybridWeb/issues/10).
- Add error UI with customizable label and reload button to `WebViewController`.
- Retain web view base URL when loading web view controller

# [0.0.4](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.4)

- Added `popToRootWebViewController ` method for popping nav controller of web view to root
- Added `presentModal()` and `dismissModal()` JS methods for navigating modal web views
- Addded `presentModalWebViewController` method to `WebViewController` for animating modal transitions

# [0.0.3](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.3)

- Added `WebViewControllerDelegate` protocol for working with `WebViewController` loading events
- Added `delegate` property to `WebViewController`
- Added [navigation bar API](https://github.com/Electrode-iOS/ELHybridWeb/blob/master/platformAPI.md#nativebridgenavigationbar-object). Fixes [#5](https://github.com/Electrode-iOS/ELHybridWeb/issues/5).
- Removed `updatePageState()` API method. Use navigation bar API to set page title now. 
- Set `goBackInWebViewOnAppear` for web pushes only in order to fix navigation inconsistencies with native transitions
- Fixed issue with flashes on back, memory usage being excessive, and Z-order issues. Fixes [#4](https://github.com/Electrode-iOS/ELHybridWeb/issues/4).
- Lazy load web view so the delegate is set after web view initialization. Fixes an issue with UIWebView delegate method not being called.
- Removed click delay in web view taps. Fixes [#3](https://github.com/Electrode-iOS/ELHybridWeb/issues/3).
- Added unit tests for web view controller delegate methods

# [0.0.2](https://github.com/Electrode-iOS/ELHybridWeb/releases/tag/v0.0.2)

- Added support for installation via Carthage
