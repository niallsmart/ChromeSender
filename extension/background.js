
window.debug = {
	log: function() {
		var ar = _.toArray(arguments);
		ar.splice(0, 0, "ChromeSender> ");
		console.log.apply(console, ar);
	}
};

chrome.tabs.onActiveChanged.addListener(function(tabId, selectInfo) {
	debug.log("tabs.onActiveChanged: ", tabId);
	localStorage.activeTabId = tabId;
});


chrome.windows.onFocusChanged.addListener(function(windowId) {
	debug.log("window.onFocusChanged: ", windowId);
	chrome.tabs.getSelected(windowId, function(tab) {
		localStorage.activeTabId = tab.id;
	})
});