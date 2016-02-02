////////////////////////////////////////////////////////////////////
// Copy and paste these into the Safari Inspector
////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// NativeBridge.dialog tests
////////////////////////////////////////////////////////////////////

// 1: missing actions
var testDialogOptions = {"title": "The title", "message":"The message"};
window.NativeBridge.dialog(testDialogOptions, function(error, id) {
  console.log("Test failed");
});

// 2: missing title and message
var testDialogOptions = {"foo": "bar"};
window.NativeBridge.dialog(testDialogOptions, function(error, id) {
  console.log("Test failed");
});

// 3: legit one button
var testDialogOptions = {"title": "The title", "message":"The message", "actions":[{"id":"ok", "label":"OK"}]};
window.NativeBridge.dialog(testDialogOptions, function(error, id) {
	if (id=="ok")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

// 3: legit one button
var testDialogOptions = {"title": "The title", "message":"The message", "actions":[{"id":"ok", "label":"OK"}]};
window.NativeBridge.dialog(testDialogOptions, function(error, id) {
	if (id=="ok")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

// 4: legit two buttons OK clicked
var testDialogOptions = {"title": "The title", "message":"The message", "actions":[{"id":"ok", "label":"OK"}, {"id":"cancel", "label":"Cancel"}]};
window.NativeBridge.dialog(testDialogOptions, function(error, id) {
	if (id=="ok")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

// 5: legit two buttons Cancel clicked
var testDialogOptions = {"title": "The title", "message":"The message", "actions":[{"id":"ok", "label":"OK"}, {"id":"cancel", "label":"Cancel"}]};
window.NativeBridge.dialog(testDialogOptions, function(error, id) {
	if (id=="cancel")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

////////////////////////////////////////////////////////////////////
// NativeBridge.share tests
////////////////////////////////////////////////////////////////////
// 1. A well formed call
var shareOptions = {
  message: "What is your quest?", 
  url: "https://github.com/Electrode-iOS/BridgeOfDeath"
};
NativeBridge.share(shareOptions);

// 2. No url
var shareOptions = {
  message: "What is your quest?", 
};
NativeBridge.share(shareOptions);

// 2. No message
var shareOptions = {
  url: "https://github.com/Electrode-iOS/BridgeOfDeath"
};
NativeBridge.share(shareOptions);

////////////////////////////////////////////////////////////////////
// NativeBridge.navigation.animateForward tests
////////////////////////////////////////////////////////////////////
NativeBridge.navigation.animateForward();

////////////////////////////////////////////////////////////////////
// NativeBridge.navigation.animateBackward tests
////////////////////////////////////////////////////////////////////
NativeBridge.navigation.animateBackward();

////////////////////////////////////////////////////////////////////
// NativeBridge.navigation.presentModal tests
////////////////////////////////////////////////////////////////////
NativeBridge.navigation.presentModal();

////////////////////////////////////////////////////////////////////
// NativeBridge.navigation.dismissModal tests
////////////////////////////////////////////////////////////////////
NativeBridge.navigation.dismissModal();


////////////////////////////////////////////////////////////////////
// NativeBridge.navigationBar.setTitle tests
// Test this after NativeBridge.navigation.presentModal too
////////////////////////////////////////////////////////////////////
NativeBridge.navigationBar.setTitle("Test title"); 

////////////////////////////////////////////////////////////////////
// NativeBridge.navigationBar.setButtons tests
// Test this after NativeBridge.navigation.presentModal too
////////////////////////////////////////////////////////////////////

// 1: legit two buttons Cancel clicked
var buttons = [{
  title: "Cancel",
  id: "cancel"
}, {
  title: "Done",
  id: "done"
}];
window.NativeBridge.navigationBar.setButtons(buttons, function (buttonID) {
	if (buttonID=="cancel")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

// 2: legit two buttons Done clicked
var buttons = [{
  title: "Cancel",
  id: "cancel"
}, {
  title: "Done",
  id: "done"
}];
window.NativeBridge.navigationBar.setButtons(buttons, function (buttonID) {
	if (buttonID=="done")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

// 3: malformed data
var buttons = [{
  foo: "Cancel",
  bar: "cancel"
}, {
  foo: "Done",
  bar: "done"
}];
window.NativeBridge.navigationBar.setButtons(buttons, function (buttonID) {
	if (buttonID=="done")
  		console.log("Test passed");
  	else 
	  	console.log("Test failed");
});

// 4. Remove buttons
window.NativeBridge.navigationBar.setButtons(null, null);

// 5. Remove buttons
window.NativeBridge.navigationBar.setButtons(null);

// 6. Remove buttons
window.NativeBridge.navigationBar.setButtons([]);

