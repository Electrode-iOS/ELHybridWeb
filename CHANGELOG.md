# [0.1.0](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.1.0)

- Make `showWebView()` public
- Added `popToRoot()` method in navigation API. Fixes [#32](https://github.com/TheHolyGrail/Zoot/issues/32)
- Wait for view.show() bridge call to unhide web view after `animateForward()` and `presentModal()`. Fixes [#30](https://github.com/TheHolyGrail/Zoot/issues/30). You must now explicitly call `view.show()` to show the web view after a call to `navigation.animateForward()` or `navigation.presentModal()`.
- Removed delay before showing web view
- Update `WebViewController` to trigger onAppear/onDisappear JS callbacks. Fixes [#29](https://github.com/TheHolyGrail/Zoot/issues/29)
- Added `onAppear` and `onDisappear` JS callbacks to view API
- Added view API with show() method for unhiding web view

# [0.0.8](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.8)

- Added `info()` hybrid API method for getting device information.
- Added noframeworks check to add compile by source compatibility
- Added unit test for initializing `WebViewController` subclasses
- Update `WebViewController` initializer to be designated
- Added `JSValue` extension method for safely converting string values
- Pass errors back to `dialog()` callback when missing required options parameters

# [0.0.7](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.7)

- `WebViewController` now uses `dynamicType` when spawning new web view controllers instances in order to support subclassed types.
- Avoid goBack in web history when `animateBackward` is called. Fixes [#16](https://github.com/TheHolyGrail/Zoot/issues/16)
- Track the web view's first completed loading cycle. Fixes [#15](https://github.com/TheHolyGrail/Zoot/issues/15), a bug that was causing the web view to remain in a hidden state after making `presentModal()` and `animateForward()` bridge calls.

# [0.0.6](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.6)

- Default to presenting modal from tab bar controller if one exists when calling `presentModal()`

# [0.0.5](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.5)

- Avoid going back in web history after dismissing a modal view controller with `dismissModal()`. Fixes [#11](https://github.com/TheHolyGrail/Zoot/issues/11).
- Navigation bar items are removed when `null` or empty array is passed to `setButtons` from JS. Fixes [#9](https://github.com/TheHolyGrail/Zoot/issues/9).
- Propagate hybrid API's `parentViewController` change to navigation bar API. Fixes [#10](https://github.com/TheHolyGrail/Zoot/issues/10).
- Add error UI with customizable label and reload button to `WebViewController`.
- Retain web view base URL when loading web view controller

# [0.0.4](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.4)

- Added `popToRootWebViewController ` method for popping nav controller of web view to root
- Added `presentModal()` and `dismissModal()` JS methods for navigating modal web views
- Addded `presentModalWebViewController` method to `WebViewController` for animating modal transitions

# [0.0.3](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.3)

- Added `WebViewControllerDelegate` protocol for working with `WebViewController` loading events
- Added `delegate` property to `WebViewController`
- Added [navigation bar API](https://github.com/TheHolyGrail/Zoot/blob/master/platformAPI.md#nativebridgenavigationbar-object). Fixes [#5](https://github.com/TheHolyGrail/Zoot/issues/5).
- Removed `updatePageState()` API method. Use navigation bar API to set page title now. 
- Set `goBackInWebViewOnAppear` for web pushes only in order to fix navigation inconsistencies with native transitions
- Fixed issue with flashes on back, memory usage being excessive, and Z-order issues. Fixes [#4](https://github.com/TheHolyGrail/Zoot/issues/4).
- Lazy load web view so the delegate is set after web view initialization. Fixes an issue with UIWebView delegate method not being called.
- Removed click delay in web view taps. Fixes [#3](https://github.com/TheHolyGrail/Zoot/issues/3).
- Added unit tests for web view controller delegate methods

# [0.0.2](https://github.com/TheHolyGrail/Zoot/releases/tag/v0.0.2)

- Added support for installation via Carthage
