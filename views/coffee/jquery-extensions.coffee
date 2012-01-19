

jQuery.fn.flash = () ->
  this.removeClass("flash")
  setTimeout (() => this.addClass("flash")), 0

jQuery.fn.borderWidth = () ->
  parseInt(this.css("border-left-width"), 10) + parseInt(this.css("border-right-width"), 10)
