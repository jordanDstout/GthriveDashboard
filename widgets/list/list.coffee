#require 'Time'
#require 'moment'


class Dashing.List extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()
    
  onData: (data) ->
    $(@node).css('fill-color', '#00FF00')
    #for x in data['items']
    #    try
    #        x['value']=Time.parse(x['value'])
    #    catch
    #        $(@node).css('background-color', '#00ff00')
    #    
    #    difference=moment.utc(moment(x['value'],"DD/MM/YYYY HH:mm:ss").diff(moment(then,"DD/MM/YYYY HH:mm:ss"))).format("HH:mm:ss")
    #    if difference>moment.utc(moment('1:00:00',"DD/MM/YYYY HH:mm:ss").format("HH:mm:ss")
    #        $(@node).css('background-color', '#ff0000')