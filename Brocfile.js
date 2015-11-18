/* Brocfile.js */

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
var clStyle = compileSass([sassDir], 'craigslist_listing.scss', 'craigslist_listing.css');

var scripts = browserify(coffeeDir, {
    bundles: {
        "craigslist_listing.js": {
            transform: [
                require('coffee-reactify')
            ],
            entryPoints: ['craigslist_listing.coffee']
        }
    }
});

var resourceFiles = new Funnel(resources, {
    //destDir: resources
});

// Merge the compiled styles and scripts into one output directory.
module.exports = mergeTrees([clStyle, scripts, resourceFiles]);
