
window.debug = {
	log: function() {
		var ar = _.toArray(arguments);
		ar.splice(0, 0, "ChromeSender> ");
		console.log.apply(console, ar);
	}
};

chrome.tabs.onActiveChanged.addListener(function(tabId, selectInfo) {
	debug.log("tabs.onActiveChanged: id", tabId);
	localStorage.activeTabId = tabId;
});