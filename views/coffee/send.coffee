
keyCodeComma = 44
keyCodeEnter = 13
keyCodeDelete = 8

class AutoComplete extends Backbone.View

  initialize: (options) =>
    options ||= {}
    @minEditorWidth = options.minEditorWidth || 200
    @$el = $(@el)
    @editor = $(".editor")
    @fixEditorWidth()

    @options = options

    @editor.autocomplete
      source: options.source
      autoFocus: true
      delay: 0
      position:
        of: @editor
        at: "left bottom"
        offset: "3 3"
      open: () =>
        @editor.autocomplete("widget") #.width(200) #.css("margin-top", "-0px")
      focus: () =>
        false
      select: (event, ui) =>
        console.log(arguments)
        @editor.val(ui.item.label)
        @addItem()
        event.preventDefault()
        false

  addItem: =>
    item = $("<span tabindex='10' class='item'></span>")
    item.text(@transformItem(@editor.val()))
    item.append("<a tabindex='-1' class='remove' href='#'>&times;</a></span>");
    @editor.before(item);
    @editor.val('');
    @fixEditorWidth()

  removeItem: (item) =>
    return unless item.length
    item.next().focus()
    item.detach()
    @fixEditorWidth()

  fixEditorWidth: =>

    lastItem = @$(".item").last()

    if lastItem.size()
      width = @$el.innerWidth() - (lastItem.position().left + lastItem.outerWidth(true));

    if !lastItem.size() || width < @minEditorWidth
      width = @$el.innerWidth()

    #@editor.width(width - (@editor.outerWidth() - @editor.innerWidth())
    @editor.width(width - (@editor.outerWidth(true) - @editor.innerWidth()))

  itemKeydown: (ev) =>
    if ev.keyCode == keyCodeDelete
      ev.preventDefault()
      @removeItem $(ev.target)

  itemRemoveClick: (ev) =>
    ev.preventDefault()
    @removeItem $(ev.target).closest(".item")

  acceptItem: (item) ->
    true

  transformItem: (item) ->
    item

  editorKeyPress: (ev) =>
    if ev.keyCode in [keyCodeEnter] and @editor.val().length
      if @acceptItem(@editor.val())
        ev.preventDefault()
        @addItem()
      else
        @editor.flash();


  editorKeyDown: (ev) =>
    if ev.keyCode == keyCodeDelete && !@editor.val()
      ev.preventDefault();
      @removeItem @editor.prev(".item")


  events:
    "keypress .editor":         "editorKeyPress"
    "keydown  .editor":         "editorKeyDown"
    "keydown  .item":           "itemKeydown"
    "click    .item .remove":   "itemRemoveClick"



class EMailAutoComplete extends AutoComplete

  parseEmail: (str) =>
    str = str.replace(/(^\s+)|(\s+$)/g, "");
    nonAtDot = "[^@\"']+"
    email = "#{nonAtDot}\\@#{nonAtDot}\\.#{nonAtDot}"
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

  acceptItem: (val) =>
    @parseEmail(val)

  transformItem: (val) =>
    address = @parseEmail(val)
    address.name || address.email


root = exports ? this
root.AutoComplete = AutoComplete
root.EMailAutoComplete = EMailAutoComplete