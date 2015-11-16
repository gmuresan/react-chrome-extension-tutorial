ReactDOM = require 'react-dom'
React = require 'react'
LinkedStateMixin = require 'react-addons-linked-state-mixin'
Parse = require 'parse'
Parse.initialize("Ee2FI97fstyJnca8vv8CBAesQRDhJd2Xf6flFgqw", "PPtqcZ8seAaKaAfOoafB8T1J3oSjU9G29mNQbYEP")

phoneNumRegex = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/

messageDiv = $("<a href='#'>Message</a>")
messageDiv.click ->
  showContact = $('.showcontact').first()
  contactUrl = showContact.attr('href')
  $.ajax(
    url: contactUrl
    context: document.body
  ).then (data, status, xhr) ->
    numbers = phoneNumRegex.exec(data)
    if numbers?.length? and number = numbers[0].trim()
      console.log(number)
      if not $('#clMessageDiv')?.length
        $('#pagecontainer .body').append('<div id="clMessageDiv"></div>')

      ReactDOM.render(
        <MessageBox phoneNumber=number />
        document.getElementById('clMessageDiv')
      )

  , (xhr, status, error) ->
    debugger

messageDiv.appendTo('.body .postingtitle')
messageDiv.trigger('click')

recipient = 'sms'

MessageBox = React.createClass({
  displayName: 'MessageBox'
  mixins: [LinkedStateMixin]

  render: ->
    <div>
      {@props.phoneNumber}
      <RecipientSelector />
      <br />
      <MessageLog messages={@state.messages} />
      <br />
      <MessageInput onSubmit={@submit} messageState={@linkState('currentMessage')} />
    </div>

  getInitialState: ->
    messages: []
    currentMessage: ''

  componentDidMount: ->

  componentWillUnmount: ->

  submit: ->
    thiz = @
    if recipient == 'sms'
      Parse.Cloud.run 'sendMessage', {phone: '7345783863', message: @state.currentMessage}, {
        success: (success) ->
          console.log(success)
          thiz.addCurrentMessage()

        error: (error) ->
          console.log(error)
      }
    else
      Parse.Cloud.run 'sendEmail', {email: 'george@trydweller.com', message: @state.currentMessage}, {
        success: (success) ->
          console.log(success)
          thiz.addCurrentMessage()

        error: (error) ->
          console.log(error)

      }

  addCurrentMessage: ->
    messages = @state.messages
    messages.push(@state.currentMessage)
    @setState
      currentMessage: ''
      messages: messages

})

RecipientSelector = React.createClass({
  displayName: 'RecipientSelector'

  render: ->
    <div>
      <select onChange={@onChange}>
        <option value='sms'>SMS</option>
        <option value='email'>Email</option>
      </select>
    </div>

  onChange: (event) ->
    val = event.target.value
    recipient = val
})

MessageLog = React.createClass({
  displayName: 'MessageLog'

  render: ->
    <div className='message-log'>
      {
        @props.messages.map (message) ->
          return <div>{message}</div>
      }
    </div>
})

MessageInput = React.createClass({
  displayName: 'MessageInput'

  render: ->
    <div>
      <textarea valueLink={@props.messageState}
        rows=3 cols=50 name='message' className='message-input-box' />

      <button onClick={@props.onSubmit}>Submit</button>
    </div>

})

