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
var appStyle = compileSass([sassDir], 'app.scss', 'app.css');
var clStyle = compileSass([sassDir], 'craigslist.scss', 'craigslist.css');
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
module.exports = mergeTrees([appStyle, clStyle, clListingStyle, scripts, resourceFiles]);
