[![Contact me on Codementor](https://cdn.codementor.io/badges/contact_me_github.svg)](https://www.codementor.io/gmuresan?utm_source=github&utm_medium=button&utm_term=gmuresan&utm_campaign=github)

React is a great new way to write the frontend of your app. It allows you to separate each component of your UI into a separate class which reduces the complexity that you need to worry about at any one time. You can freely make changes to one component without having to worry about how it will affect every other part of your website.

Most React tutorials focus on starting with a blank web page on your own website and adding your own HTML code to create the UI. Today I'll show you how to use React to add some UI on top of a current website. We're going to do this by creating a [Chrome Extension](https://developer.chrome.com/extensions), which is a small software program that can modify and enhance the functionality of the Chrome browser. After this tutorial you should be able to easily take what you've learned and use React to create Firefox and Safari extensions with a little modification.

Our extension is going to run on top of Craigslist. It will allow you to make notes about listings that you have viewed and to view those notes when you are viewing the listing. You can grab the completed project on [Github](https://github.com/gmuresan/react-chrome-extension-tutorial).

## Setting up the project

You're going to want to create a new folder for your project. For the tutorial I will be using the following project structure

```
tutorial/
  app/
    coffee/
      craigslist_listing.coffee
    scss/
      craigslist_listing.scss
  res/
    manifest.json
  package.json
  Brocfile.js
```

## Package.json

As with any React project we'll use a package.json file to describe our project and manage our external dependencies. Let's start with a bare file and then we'll add our dependencies after.

```
{
  "name": "tutorial",
  "description": "chrome extension",
  "version": "0.0.1",
  "author": "gmuresan",
  "license": "ISC",
  "main": "",
  "private": true,
  "scripts": {},
  "dependencies": {}
}
```

Now let's add the libraries we will be using. First let's install React.

```
npm install --save-dev react react-dom
```

Since we will be using Coffeescript and JSX for our React files, we need a way to convert those files into javascript so the browser can understand and run the code. To do that, we will be using [Broccoli](http://broccolijs.com/). To install Broccoli use the following two commands inside your project directory

```
npm install -g broccoli-cli
npm install --save-dev broccoli
```

Now that Broccoli is installed, we also need to add all the libraries that Broccoli needs to compile our Coffeescript and SASS files, and to package our files together so Chrome can install the extension.

```
npm install --save-dev broccoli-sass broccoli-fast-browserify broccoli-merge-trees broccoli-funnel coffee-reactify broccoli-timepiece
```

## The Manifest File

The manifest is the heart of any Chrome extension. It tells Chrome “here’s what I am, and here’s what I need to work.” Our file will be located at `res/manifest.json`.

```
{
    "manifest_version": 2,

    "name": "Craigslist Notes Extension",
    "description": "This Extension will allow you to write notes about different Craigslist listings and view those notes on the page",
    "version": "1.0",

    "permissions": [
      "activeTab"
    ],

    "content_scripts": [
        {
            "matches": ["*://*.craigslist.org/*.html"],
            "css": ["craigslist_listing.css"],
            "js": ["craigslist_listing.js"]
        }
    ]
}

```

- The `permissions` property will tell Chrome that our extension needs to run it's scripts on the currently active tab in Chrome.
- The `content__scripts` property will tell Chrome that when the URL of the current page matches a certain pattern, then we want to inject certain javascript and html files. In this case when the URL is a Craigslist listing, then we want to inject our `craigslist_listing.css` and `craigslist_listing.js` files.

## Building the project with Broccoli

We are going to use Brocfile.js to tell Broccoli how we want our project to be built. Broccoli will be compiling our SASS files into CSS, it will take our CJSX files and convert them to regular CoffeeScript files, and then turn those CoffeeScript files into JavaScript files, and finally it will copy these compiled files along with any static files we have into our output directory.

```
// Import some Broccoli plugins
var compileSass = require('broccoli-sass');
var mergeTrees = require('broccoli-merge-trees');
var Funnel = require('broccoli-funnel');
var browserify = require('broccoli-fast-browserify')

// Specify the Sass and Coffeescript directories
var sassDir = 'app/scss';
var coffeeDir = 'app/coffee';
var manifest = 'manifest.json';
var resources = 'res'

// Tell Broccoli how we want the assets to be compiled
var clListingStyle = compileSass([sassDir], 'craigslist_listing.scss', 'craigslist_listing.css');

var scripts = browserify(coffeeDir, {
    bundles: {
        "load_craigslist_listing.js": {
            transform: [
                require('coffee-reactify')
            ],
            entryPoints: ['load_craigslist_listing.coffee']
        },
        "load_craigslist.js": {
            transform: [
                require('coffee-reactify')
            ],
            entryPoints: ['load_craigslist.coffee']
        }
    }
});

var resourceFiles = new Funnel(resources, {
    //destDir: resources
});

// Merge the compiled styles and scripts into one output directory.
module.exports = mergeTrees([clListingStyle, scripts, resourceFiles]);
```

## Content Scripts

Now we are going to create our CoffeeScript and SASS files that contain the actual functionality of our Chrome Extension. First `craigslist_listing.coffee`:

```
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

# Here we find the 'mapAndAttr' div, we insert our own div as one of it's children,
# then we render our React component inside the new div
attrsDiv = window.document.getElementsByClassName('mapAndAttrs')?[0]
if attrsDiv
  notesDiv = document.createElement('div')
  notesDiv.id='clNotes'
  attrsDiv.appendChild(notesDiv)

  ReactDOM.render(
    <CLNotes />
    document.getElementById('clNotes')
  )

```

We start out with our top level React component "CLNotes". This contains two child components, one for displaying our notes, and one for inputting new notes. Next come our input and display components and the logic for saving notes and displaying all of our current notes.

At the bottom of the file, after the React components, we have the code that gets executed when the page is loaded. Here we insert a new div inside the listing page, and then we render our React component inside this new div.

Our `craigslist_listing.scss` file is very simple. We will just add some styling to make the background grey, and to set the sizes of our components.

```
#clNotes {
  width: 300px;
  height: 300px;
  background-color: lightgrey;
  padding:15px;
}

#notesDisplay {
  width:270px;
  height: 230px;
  background-color: white;
  overflow-y: scroll;
}
```

## Installing and running our chrome extension

First we need to compile our files using Broccoli. Inside the project directory, in a terminal, you will run 
```
broccoli-timepiece dist/
```

This command will compile our project into the `dist/` directory and it will keep recompiling the project automatically if you make any future changes.

After this command succeeds, open up Chrome and navigate to `chrome://extensions`. In the top right, make sure "Developer mode" is selected, then click on "Load unpacked extension...". Navigate to our `dist/` folder, select it and press OK.

Now open up a Craigslist listing (such as [https://sfbay.craigslist.org/scz/roo/5295933277.html](https://sfbay.craigslist.org/scz/roo/5295933277.html)). You should see a grey box to the right of the images, where you can input text and then display in the list by pressing the save button.

![Demo](https://www.filepicker.io/api/file/8q6Q7TR1Q1OAhiK0dxCm "enter image title here")

## Next steps

This extension is not very useful right now. The notes won't save if you navigate away from the page. As a further learning exercise, try saving your notes on a server, such as [Parse](https://parse.com/), and the load them into the page when the page loads.

If you're going to create a larger extension with many React components, I would also look into a state storage mechanism like [Redux](https://github.com/rackt/redux).
