
chrome.extension.onRequest.addListener(
	function (request, sender, sendResponse) {

		console.log(request)

		if (request.method == "pageInfo")
			handleGetPageInfo(request, sender, sendResponse);
		else
			sendResponse({}); // snub them.
	}
);

function handleGetPageInfo(request, sender, sendResponse) {

	var sel = window.getSelection(),
		text = null,
		response;

	if (sel.rangeCount > 0) {
		text = sel.getRangeAt(0).toString().trim();

		if (text.length == 0) {
			text = null;
		}
	}

	response = {
		selection: text,
		href: window.location.href,
		title: document.title.trim()
	};

	console.log(response);

	sendResponse(response);
}

