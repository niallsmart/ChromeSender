

class window.Messenger
  @instance: () ->
    @__instance ||= new (if chrome?.tabs? then BackgroundMessager else DummyMessenger)


class BackgroundMessager extends Messenger

  getPageInfo: (composer) ->
    @doRequest parseInt(localStorage.activeTabId, 0), "pageInfo", null, composer

  doRequest: (tabId, method, params, callback) ->

    suffix = "#{method[0].toUpperCase()}#{method[1..]}"
    getter = "get#{suffix}"
    setter = "set#{suffix}"
    request = _.defaults({method: method}, params)

    chrome.tabs.sendRequest tabId, request, (response) ->
      callback[setter](response)


class DummyMessenger extends Messenger

  getPageInfo: (composer) ->
    composer.setPageInfo
      title: "fake title",
      href: "http://fake.com",
      selection: "Dog bites man!"