

jQuery.fn.flash = (selectAfter) ->
  this.removeClass("flash")
  #this.one "webkitAnimationEnd", (ev) =>
  #  this.select() if selectAfter and ev.originalEvent.animationName == 'flash'
  setTimeout (() => this.addClass("flash")), 0
  this

jQuery.fn.borderWidth = () ->
  parseInt(this.css("border-left-width"), 10) + parseInt(this.css("border-right-width"), 10)
