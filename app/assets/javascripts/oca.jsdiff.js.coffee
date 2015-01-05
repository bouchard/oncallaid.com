# Custom class by Brady Bouchard to do convenient diffs using jsdiff.js.

$ ->

  window.OCA ||= {}

  class OCA.JsDiff

    constructor: (outputDiv, oldTextarea, newTextarea) ->
      @outputDiv = $(outputDiv)
      @oldTextarea = $(oldTextarea)
      @newTextarea = $(newTextarea)
      @newTextarea.on 'change.diff', $.proxy(@_doDiff, this)

    _doDiff: ->

      diff = JsDiff.diffLines(@oldTextarea, @newTextarea)
      @outputDiv.html('')

      for el, i in diff
        if diff[i].added && diff[i + 1] && diff[i + 1].removed
          swap = diff[i]
          diff[i] = diff[i + 1]
          diff[i + 1] = swap
        if diff[i].removed
          @outputDiv.append $('<del>').text(diff[i].value)
        else if diff[i].added
          @outputDiv.append $('<ins>').text(diff[i].value)
        else
          @outputDiv.append diff[i].value