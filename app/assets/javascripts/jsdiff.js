/* See license.txt for terms of usage */

/*
 * Text diff implementation.
 *
 * This library supports the following APIS:
 * JsDiff.diffChars: Character by character diff
 * JsDiff.diffWords: Word (as defined by \b regex) diff which ignores whitespace
 * JsDiff.diffLines: Line based diff
 *
 * JsDiff.diffCss: Diff targeted at CSS content
 *
 * These methods are based on the implementation proposed in
 * "An O(ND) Difference Algorithm and its Variations" (Myers, 1986).
 * http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.4.6927
 */
var JsDiff = (function() {
  function clonePath(path) {
    return { newPos: path.newPos, components: path.components.slice(0) };
  }
  function removeEmpty(array) {
    var ret = [];
    for (var i = 0; i < array.length; i++) {
      if (array[i]) {
        ret.push(array[i]);
      }
    }
    return ret;
  }
  function escapeHTML(s) {
    var n = s;
    n = n.replace(/&/g, "&amp;");
    n = n.replace(/</g, "&lt;");
    n = n.replace(/>/g, "&gt;");
    n = n.replace(/"/g, "&quot;");

    return n;
  }


  var fbDiff = function(ignoreWhitespace) {
    this.ignoreWhitespace = ignoreWhitespace;
  };
  fbDiff.prototype = {
      diff: function(oldString, newString) {
        // Handle the identity case (this is due to unrolling editLength == 0
        if (newString == oldString) {
          return [{ value: newString }];
        }
        if (!newString) {
          return [{ value: oldString, removed: true }];
        }
        if (!oldString) {
          return [{ value: newString, added: true }];
        }

        newString = this.tokenize(newString);
        oldString = this.tokenize(oldString);

        var newLen = newString.length, oldLen = oldString.length;
        var maxEditLength = newLen + oldLen;
        var bestPath = [{ newPos: -1, components: [] }];

        // Seed editLength = 0
        var oldPos = this.extractCommon(bestPath[0], newString, oldString, 0);
        if (bestPath[0].newPos+1 >= newLen && oldPos+1 >= oldLen) {
          return bestPath[0].components;
        }

        for (var editLength = 1; editLength <= maxEditLength; editLength++) {
          for (var diagonalPath = -1*editLength; diagonalPath <= editLength; diagonalPath+=2) {
            var basePath;
            var addPath = bestPath[diagonalPath-1],
                removePath = bestPath[diagonalPath+1];
            oldPos = (removePath ? removePath.newPos : 0) - diagonalPath;
            if (addPath) {
              // No one else is going to attempt to use this value, clear it
              bestPath[diagonalPath-1] = undefined;
            }

            var canAdd = addPath && addPath.newPos+1 < newLen;
            var canRemove = removePath && 0 <= oldPos && oldPos < oldLen;
            if (!canAdd && !canRemove) {
              bestPath[diagonalPath] = undefined;
              continue;
            }

            // Select the diagonal that we want to branch from. We select the prior
            // path whose position in the new string is the farthest from the origin
            // and does not pass the bounds of the diff graph
            if (!canAdd || (canRemove && addPath.newPos < removePath.newPos)) {
              basePath = clonePath(removePath);
              this.pushComponent(basePath.components, oldString[oldPos], undefined, true);
            } else {
              basePath = clonePath(addPath);
              basePath.newPos++;
              this.pushComponent(basePath.components, newString[basePath.newPos], true, undefined);
            }

            var oldPos = this.extractCommon(basePath, newString, oldString, diagonalPath);

            if (basePath.newPos+1 >= newLen && oldPos+1 >= oldLen) {
              return basePath.components;
            } else {
              bestPath[diagonalPath] = basePath;
            }
          }
        }
      },

      pushComponent: function(components, value, added, removed) {
        var last = components[components.length-1];
        if (last && last.added === added && last.removed === removed) {
          // We need to clone here as the component clone operation is just
          // as shallow array clone
          components[components.length-1] =
            {value: this.join(last.value, value), added: added, removed: removed };
        } else {
          components.push({value: value, added: added, removed: removed });
        }
      },
      extractCommon: function(basePath, newString, oldString, diagonalPath) {
        var newLen = newString.length,
            oldLen = oldString.length,
            newPos = basePath.newPos,
            oldPos = newPos - diagonalPath;
        while (newPos+1 < newLen && oldPos+1 < oldLen && this.equals(newString[newPos+1], oldString[oldPos+1])) {
          newPos++;
          oldPos++;

          this.pushComponent(basePath.components, newString[newPos], undefined, undefined);
        }
        basePath.newPos = newPos;
        return oldPos;
      },

      equals: function(left, right) {
        var reWhitespace = /\S/;
        if (this.ignoreWhitespace && !reWhitespace.test(left) && !reWhitespace.test(right)) {
          return true;
        } else {
          return left == right;
        }
      },
      join: function(left, right) {
        return left + right;
      },
      tokenize: function(value) {
        return value;
      }
  };

  var CharDiff = new fbDiff();

  var WordDiff = new fbDiff(true);
  WordDiff.tokenize = function(value) {
    return removeEmpty(value.split(/(\s+|\b)/g));
  };

  var CssDiff = new fbDiff(true);
  CssDiff.tokenize = function(value) {
    return removeEmpty(value.split(/([{}:;,]|\s+)/g));
  };

  var LineDiff = new fbDiff();
  LineDiff.tokenize = function(value) {
    var values = value.split(/\n/g),
        ret = [];
    for (var i = 0; i < values.length-1; i++) {
      ret.push(values[i] + "\n");
    }
    if (values.length) {
      ret.push(values[values.length-1]);
    }
    return ret;
  };

  return {
    diffChars: function(oldStr, newStr) { return CharDiff.diff(oldStr, newStr); },
    diffWords: function(oldStr, newStr) { return WordDiff.diff(oldStr, newStr); },
    diffLines: function(oldStr, newStr) { return LineDiff.diff(oldStr, newStr); },

    diffCss: function(oldStr, newStr) { return CssDiff.diff(oldStr, newStr); },

    createPatch: function(fileName, oldStr, newStr, oldHeader, newHeader) {
      var ret = [];

      ret.push("Index: " + fileName);
      ret.push("===================================================================");
      ret.push("--- " + fileName + "\t" + oldHeader);
      ret.push("+++ " + fileName + "\t" + newHeader);

      var diff = LineDiff.diff(oldStr, newStr);
      diff.push({value: "", lines: []});   // Append an empty value to make cleanup easier

      var oldRangeStart = 0, newRangeStart = 0, curRange = [],
          oldLine = 1, newLine = 1;
      for (var i = 0; i < diff.length; i++) {
        var current = diff[i],
            lines = current.lines || current.value.replace(/\n$/, "").split("\n");
        current.lines = lines;

        if (current.added || current.removed) {
          if (!oldRangeStart) {
            var prev = diff[i-1];
            oldRangeStart = oldLine;
            newRangeStart = newLine;

            if (prev) {
              curRange.push.apply(curRange, prev.lines.slice(-4).map(function(entry) { return " " + entry; }));
              oldRangeStart -= 4;
              newRangeStart -= 4;
            }
          }
          curRange.push.apply(curRange, lines.map(function(entry) { return (current.added?"+":"-") + entry; }));
          if (current.added) {
            newLine += lines.length;
          } else {
            oldLine += lines.length;
          }
        } else {
          if (oldRangeStart) {
            if (lines.length <= 8 && i < diff.length-1) {
              // Overlapping
              curRange.push.apply(curRange, lines.map(function(entry) { return " " + entry; }));
            } else {
              // end the range and output
              var contextSize = Math.min(lines.length, 4);
              ret.push(
                  "@@ -" + oldRangeStart + "," + (oldLine-oldRangeStart+contextSize)
                  + " +" + newRangeStart + "," + (newLine-newRangeStart+contextSize)
                  + " @@");
              ret.push.apply(ret, curRange);
              ret.push.apply(ret, lines.slice(0, contextSize).map(function(entry) { return " " + entry; }));

              oldRangeStart = 0;  newRangeStart = 0; curRange = [];
            }
          }
          oldLine += lines.length;
          newLine += lines.length;
        }
      }
      if (diff.length > 1 && !/\n$/.test(diff[diff.length-2].value)) {
        ret.push("\\ No newline at end of file\n");
      }

      return ret.join("\n");
    },

    convertChangesToXML: function(changes){
      var ret = [];
      for ( var i = 0; i < changes.length; i++) {
        var change = changes[i];
        if (change.added) {
          ret.push("<ins>");
        } else if (change.removed) {
          ret.push("<del>");
        }

        ret.push(escapeHTML(change.value));

        if (change.added) {
          ret.push("</ins>");
        } else if (change.removed) {
          ret.push("</del>");
        }
      }
      return ret.join("");
    }
  };
})();