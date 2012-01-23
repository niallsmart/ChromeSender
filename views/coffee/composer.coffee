
availableItems = [
    "\"Cormac Driver\" <cormac.driver@gmail.com>",
    "\"Michael Donohoe\" <donohoe@gmail.com>",
    "\"Kathryn Smart\" <kathryn.smart@gmail.com>",
    "\"John Smart\" <john.smart@gmail.com>",
    "\"Niall Smart\" <niall@pobox.com>",
    "\"Niall Smart\" <niall.smart@gmail.com>",
    "\"Michael Cohen\" <michaelcohen@realnetworks.edu>",
    "\"Michaelkjasldkj asldkj aslkdj alkjasdj asdjklasdj lasdj slkdj alksjd alksdj laksjd Cohen\" <michaelcohen@realnetworks.edu>",
    "\"Jeff Chasen\" <jchasen@realnetworks.edu>",
    "\"John Schussler\" <jschulssler@realnetworks.edu>",
    "\"Judy Bitterli\" <jbitterli@realnetworks.edu>",
    "\"Richard Wolpert\" <rolpwert@realnetworks.edu>",
    "\"Alan Murphy\" <alan.murphy@gmail.com>",
    "\"Paul French\" <paul.french@gmail.com>",
    "\"Daniel Strickland\" <stricko@gmail.com>"
];

availableItems.sort();

class Message extends Backbone.Model

  initialize: () ->
    @urlRoot = "/api/v1/messages"


class window.Composer extends Backbone.View

  events:
    "click .cancel":  "sendMessage"
    "click .send":    "sendMessage"

  initialize: (options) ->

    @messenger = options.messenger || Messenger.instance()

    window.ac = @recipients = new EMailAutoComplete({
        el: @$(".recipients"),
        source: availableItems,
        minEditorWidth: 1024
    });

    @recipients.editor.focus();

    @messenger.getPageInfo this


  setPageInfo: (info) ->

    message = "\n\n#{info.href}"
    message += "\n\n#{info.selection}" if info.selection?

    @setFields info.title, message

  setFields: (subject, message) ->
    @$(".message textarea").val message
    @$(".subject input").val subject


  getFields: () ->
    {
      subject: @$(".subject input").val().trim()
      message: @$(".message textarea").val().trim()
    }

  cancelMessage: () ->
    window.close()

  sendMessage: () ->

    to = @recipients.items.slice(0)

    value = @recipients.editor.val().trim()

    if value.length > 0
      if !@recipients.isValueValid(value)
        @recipients.editor.flash(true).focus()
        return
      to.push @recipients.valueToItem(value)

    if to.length == 0
      @recipients.editor.flash()
      @recipients.editor.focus()
      return

    message = new Message(_.defaults({to: _.pluck(to, "value")}, @getFields()))
    message.save()


