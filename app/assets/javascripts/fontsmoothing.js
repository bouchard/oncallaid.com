/* Modernizr 2.6.2 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-cssclasses-addtest
 */
;window.Modernizr=function(a,b,c){function u(a){j.cssText=a}function v(a,b){return u(prefixes.join(a+";")+(b||""))}function w(a,b){return typeof a===b}function x(a,b){return!!~(""+a).indexOf(b)}function y(a,b,d){for(var e in a){var f=b[a[e]];if(f!==c)return d===!1?a[e]:w(f,"function")?f.bind(d||b):f}return!1}var d="2.6.2",e={},f=!0,g=b.documentElement,h="modernizr",i=b.createElement(h),j=i.style,k,l={}.toString,m={},n={},o={},p=[],q=p.slice,r,s={}.hasOwnProperty,t;!w(s,"undefined")&&!w(s.call,"undefined")?t=function(a,b){return s.call(a,b)}:t=function(a,b){return b in a&&w(a.constructor.prototype[b],"undefined")},Function.prototype.bind||(Function.prototype.bind=function(b){var c=this;if(typeof c!="function")throw new TypeError;var d=q.call(arguments,1),e=function(){if(this instanceof e){var a=function(){};a.prototype=c.prototype;var f=new a,g=c.apply(f,d.concat(q.call(arguments)));return Object(g)===g?g:f}return c.apply(b,d.concat(q.call(arguments)))};return e});for(var z in m)t(m,z)&&(r=z.toLowerCase(),e[r]=m[z](),p.push((e[r]?"":"no-")+r));return e.addTest=function(a,b){if(typeof a=="object")for(var d in a)t(a,d)&&e.addTest(d,a[d]);else{a=a.toLowerCase();if(e[a]!==c)return e;b=typeof b=="function"?b():b,typeof f!="undefined"&&f&&(g.className+=" "+(b?"":"no-")+a),e[a]=b}return e},u(""),i=k=null,e._version=d,g.className=g.className.replace(/(^|\s)no-js(\s|$)/,"$1$2")+(f?" js "+p.join(" "):""),e}(this,this.document);

// The following is adapted from: http://wellcaffeinated.net/articles/2012/01/25/font-smoothing-detection-modernizr-style

/*
 * TypeHelpers version 1.0
 * Zoltan Hawryluk, Nov 24 2009.
 *
 * Released under the MIT License. http://www.opensource.org/licenses/mit-license.php
 *
 */

Modernizr.addTest('fontsmoothing', function() {
    // IE has screen.fontSmoothingEnabled - sweet!
    if (typeof(screen.fontSmoothingEnabled) != "undefined") {
        return screen.fontSmoothingEnabled;
    } else {
        try {
            // Create a 35x35 Canvas block.
            var canvasNode = document.createElement("canvas")
              , test = false
              , fake = false
              , root = document.body || (function () {
                    fake = true;
                    return document.documentElement.appendChild(document.createElement('body'));
              }());

            canvasNode.width = "35";
            canvasNode.height = "35"

            // We must put this node into the body, otherwise
            // Safari Windows does not report correctly.
            canvasNode.style.display = "none";
            root.appendChild(canvasNode);
            var ctx = canvasNode.getContext("2d");

            // draw a black letter "O", 32px Arial.
            ctx.textBaseline = "top";
            ctx.font = "32px Arial";
            ctx.fillStyle = "black";
            ctx.strokeStyle = "black";

            ctx.fillText("O", 0, 0);

            // start at (8,1) and search the canvas from left to right,
            // top to bottom to see if we can find a non-black pixel.  If
            // so we return true.
            for (var j = 8; j <= 32; j++) {
                for (var i = 1; i <= 32; i++) {
                    var imageData = ctx.getImageData(i, j, 1, 1).data;
                    var alpha = imageData[3];

                    if (alpha != 255 && alpha != 0) {
                        test = true; // font-smoothing must be on.
                        break;
                    }
                }
            }

            //clean up
            root.removeChild(canvasNode);
            if (fake) {
                document.documentElement.removeChild(root);
            }

            return test;
        }
        catch (ex) {
            root.removeChild(canvasNode);
            if (fake) {
                document.documentElement.removeChild(root);
            }
            // Something went wrong (for example, Opera cannot use the
            // canvas fillText() method.  Return false.
            return false;
        }
    }
});

// (function() {
//   document.getElementsByTagName('html')[0].style.fontFamily = 'Arial';
//   document.getElementsByTagName('body')[0].style.fontFamily = 'Arial';
//   var headers = document.getElementsByTagName('h1');
//   for (var i = 0; i < headers.length; i++) {
//     headers[i].style.fontFamily = 'Arial';
//   }
// })()