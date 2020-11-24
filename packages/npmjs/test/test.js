
var imagecap = require( '../index.js' );


imagecap.screencapture( function( e, url ) {
  console.log( url );
} )

