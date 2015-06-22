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
