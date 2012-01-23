
keyCodeComma = 44
keyCodeEnter = 13
keyCodeDelete = 8

class AutoComplete extends Backbone.View

  events:
    "keypress .editor":         "domEditorKeyPress"
    "keydown  .editor":         "domEditorKeyDown"
    "keydown  .item":           "domItemKeydown"
    "click    .item .remove":   "domItemRemoveClick"

  initialize: (options) =>
    options ||= {}
    @minEditorWidth = options.minEditorWidth || 250
    @$el = $(@el)
    @editor = $(".editor")
    @items = []
    @fixEditorWidth()

    @editor.autocomplete
      source: options.source
      autoFocus: true
      delay: 0
      minLength: 0
      position:
        of: @editor
        at: "left bottom"
        offset: "0 3"
      open: () =>
        @editor.autocomplete("widget").width(@editor.width() + @editor.borderWidth())
      focus: () =>
        false
      select: (event, ui) =>
        @addValue(ui.item.label)
        event.preventDefault()
        false

  addItem: (item) =>
    @items.push(item)
    span = $("<span tabindex='10' class='item'></span>")
    span.text(item.label)
    span.attr("title", item.title or item.value)
    span.append("<a tabindex='-1' class='remove' href='#'>&times;</a></span>");
    span.data("item", item)
    @editor.before(span);
    @editor.val('');
    @fixEditorWidth()

  removeItemAt: (idx) =>
    span = @$(".item").eq(idx)
    @items.splice(idx, 1)
    span.next().focus()
    span.fadeOut 100, (=> span.detach())
    @fixEditorWidth()
    return false

  fixEditorWidth: =>

    lastItem = @$(".item").last()

    if lastItem.size()
      width = @$el.innerWidth() - (lastItem.position().left + lastItem.outerWidth(true));

    if !lastItem.size() || width < @minEditorWidth
      width = @$el.innerWidth()

    adjust = @editor.outerWidth(true) - @editor.innerWidth() - @editor.borderWidth()
    @editor.width(width - adjust)

  isValueValid: (value) ->
    true

  valueToItem: (item) ->
    {
      label: item,
      value: item
    }

  addValue: (value) ->
    value ||= @editor.val()
    if value.trim().length == 0
      true
    else if !@isValueValid(value)
      @editor.flash();
      false
    else
      @addItem @valueToItem(value)
      true

  domItemKeydown: (ev) =>
    if ev.keyCode == keyCodeDelete
      ev.preventDefault()
      @removeItemAt $(ev.target).index()

  domItemRemoveClick: (ev) =>
    ev.preventDefault()
    @removeItemAt $(ev.target).closest(".item").index()

  domEditorKeyPress: (ev) =>
    if ev.keyCode in [keyCodeEnter, keyCodeComma]
      ev.preventDefault()
      @addValue()
      false

  domEditorKeyDown: (ev) =>
    if ev.keyCode == keyCodeDelete && !@editor.val()
      ev.preventDefault();
      @removeItemAt @editor.prev(".item").index()


class EMailAutoComplete extends AutoComplete

  parseEmail: (str) =>
    str = str.replace(/(^\s+)|(\s+$)/g, "");
    nonAtDotWS = "[^@\"\\s']+"
    email = "#{nonAtDotWS}\\@#{nonAtDotWS}\\.#{nonAtDotWS}"
    name = "[\"']([^\"']+)[\"']"
    regex = new RegExp("^(#{email}|#{name}\\s+<(#{email})>)$")
    ret = regex.exec(str)
    if (ret)
      {
        name: ret[2]
        email: ret[3] or ret[0]
      }
    else
      null

  isValueValid: (val) =>
    @parseEmail(val)

  valueToItem: (val) =>
    address = @parseEmail(val)
    {
      label: address.name || address.email
      value: val
    }


root = exports ? this
root.AutoComplete = AutoComplete
root.EMailAutoComplete = EMailAutoComplete