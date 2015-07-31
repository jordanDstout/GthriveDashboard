#require 'Time'
#require 'moment'


class Dashing.List extends Dashing.Widget

  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()
      
  onData: (data) ->
        #for x in data
      #for x in data
      #  if 
    $(@node).css('color', '#00ffff')