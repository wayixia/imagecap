This package is for electron windows

Install:
==
```shell
npm install imagecap
```



Electron:
==

You must disabled webSecurity when create browser window
--
```Javascript
webPreferences: {
      webSecurity: false,
}
```

Sample.html:
--
```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <!-- https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP -->
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; img-src 'self' data: base64; script-src 'self'">
    <meta http-equiv="X-Content-Security-Policy" content="default-src 'self'; script-src 'self'">
    <title>ImageCap ScreenCapture for Electron </title>
    </script>
  </head>
  <body>
    <h1> ImageCap plugin for Electron</h1>
    <button id="btn-screencap">Screen Capture</button>
    <hr>
    <img id="img-screencap" style="margin:0 auto; height: 100%;" />
    <!-- You can also require other files to run in this process -->
    <script src="./renderer.js"></script>
  </body>
</html>

```


Sample code of javascript
--
```javascript
const img = document.getElementById( 'img-screencap' );
const btn = document.getElementById( 'btn-screencap' );
btn.onclick = ()=> {
  const imagecap = require('imagecap');
  imagecap.screencapture( function( e, errorurl ) {
    if( e ) {
      // Show error message
      console.log( errorurl );
    } else {
      // Show image
      img.src = url;
    }
  });
```



