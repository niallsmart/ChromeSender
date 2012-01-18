
chrome.extension.onRequest.addListener(
	function (request, sender, sendResponse) {

		console.log(request, sender, sendResponse);

		if (request.method == "getSelectionText")
			handleGetSelectionText(request, sender, sendResponse);
		else
			sendResponse({}); // snub them.
	}
);

function handleGetSelectionText(request, sender, sendResponse) {

	var sel = window.getSelection(),
		text = null;

	if (sel.rangeCount > 0) {
		text = sel.getRangeAt(0).toString().trim();

		if (text.length == 0) {
			text = null;
		}
	}

	sendResponse({
		selection: text
	});
}

