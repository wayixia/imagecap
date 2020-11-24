


const {spawn} = require('child_process');
const appUrl = __dirname + "/bin/ImageCap.exe"


function screen_capture( f )
{
  const cap = spawn(appUrl, ["--app=screencap"] );
  let imgurl="";
  cap.stdout.on( 'data', function(s) {
    imgurl = s.toString(); 
  } );

  cap.stderr.on('data', function(s) {
    f( -1, s );
  } );

  cap.stdout.on( 'end', function() {
    console.log( "screencap end" );
    f( 0, imgurl );
  });
}


module.exports = {
  screencapture: screen_capture
}
