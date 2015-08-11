#require 'Time'
#require 'moment'


class Dashing.List extends Dashing.Widget

    ready: ->
        if @get('unordered')
            $(@node).find('ol').remove()
        else
            $(@node).find('ul').remove()
    
    
    
    
    
    #this is used to change the status of the WIDGET using the status of an individual element
    #changing the 'node' segment may help though i havent been able to get that working
    #onData: (data) ->
    #    for x in data['items']
    #        #clear existing "status-*" classes
    #        $(@get('node')).attr 'class', (i,c) ->
    #            c=c.replace /\bstatus-\S+/g, ''
    #        # add new class
    #        $(@get('node')).addClass "status-#{x.status}"