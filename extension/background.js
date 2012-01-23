
window.debug = {
	log: function() {
		var ar = _.toArray(arguments);
		ar.splice(0, 0, (new Date()).toString(), "ChromeSender> ");
		console.log.apply(console, ar);
	}
};

/*
 * TODO: Tidy this up into a setActiveTabID when
 *       the logic is known to be stable.
 */

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

chrome.windows.onFocusChanged.addListener(function(windowId) {
	debug.log("window.onFocusChanged: ", windowId);

	if (windowId > 0) {
		chrome.tabs.getSelected(windowId, function(tab) {
			debug.log("tabs.getSelected: ", windowId);
			localStorage.activeTabId = tab.id;
		})
	}
});