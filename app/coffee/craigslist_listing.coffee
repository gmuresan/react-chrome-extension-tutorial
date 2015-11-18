ReactDOM = require 'react-dom'
React = require 'react'

CLNotes = React.createClass({
  displayName: 'CLNotes'
  getInitialState: ->
    notes: []

  render: ->
    <div>
      <NotesDisplay notes={@state.notes} />
      <NoteInput saveNote={@saveNote} />
    </div>

  saveNote: (note) ->
    notes = @state.notes
    notes.push(note)
    @setState
      notes: notes
})

NoteInput = React.createClass({
  displayName: 'NoteInput'
  getInitialState: ->
    note: ''

  render: ->
    <div>
      <input type='text' value={@state.note} onChange={@noteChanged} />
      <button onClick={@saveNote}>Save</button>
    </div>

  noteChanged: (event) ->
    note = event.target.value
    @setState
      note: note

  saveNote: ->
    @props.saveNote(@state.note)
    @setState
      note: ''
})

NotesDisplay = React.createClass({
  displayName: 'NotesDisplay'

  render: ->
    <div id='notesDisplay'>
      {
        @props.notes.map (note, i) ->
          <div key={i}>
            {note}
          </div>
      }
    </div>
})

attrsDiv = window.document.getElementsByClassName('mapAndAttrs')?[0]
if attrsDiv
  notesDiv = document.createElement('div')
  notesDiv.id='clNotes'
  attrsDiv.appendChild(notesDiv)

  ReactDOM.render(
    <CLNotes />
    document.getElementById('clNotes')
  )
