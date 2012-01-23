
window.debug = {
	log: function() {
		var ar = _.toArray(arguments);
		ar.splice(0, 0, (new Date()).toString(), "ChromeSender> ");
		console.log.apply(console, ar);
	}
};

function bodyOnLoad() {
	chrome.windows.getCurrent(function(window) {
		debug.log("bodyOnLoad.windows.getCurrent", window);
		chrome.tabs.getSelected(window.id, function(tab) {
			debug.log("bodyOnLoad.tabs.getSelected", tab);
			localStorage.activeTabId = tab.id;
		})
	});
}

chrome.tabs.onActiveChanged.addListener(function(tabId, selectInfo) {
	debug.log("tabs.onActiveChanged: ", tabId);
	localStorage.activeTabId = tabId;
});

chrome.tabs.onCreated.addListener(function(windowId) {
	debug.log("tabs.onCreated: ", windowId);
});

chrome.windows.onCreated.addListener(function(windowId) {
	debug.log("window.onCreated: ", windowId);
});

chrome.windows.onFocusChanged.addListener(function(windowId) {
	debug.log("window.onFocusChanged: ", windowId);

	if (windowId > 0) {
		chrome.tabs.getSelected(windowId, function(tab) {
			localStorage.activeTabId = tab.id;
		})
	}
});