#require 'Time'
#require 'moment'


class Dashing.List extends Dashing.Widget

    ready: ->
        if @get('unordered')
            $(@node).find('ol').remove()
        else
            $(@node).find('ul').remove()
      
    onData: (data) ->
        console.log data['items']
        for x in data['items']
            #if x['status']=='warning'
             #clear existing "status-*" classes
            $(@get('node')).attr 'class', (i,c) ->
                c.replace /\bstatus-\S+/g, ''
            # add new class
            $(@get('node')).addClass "status-#{x.status}"