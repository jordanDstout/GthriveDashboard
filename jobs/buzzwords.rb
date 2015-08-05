require 'net/http'
require 'time'


#array used to track which parts of the parsed data are names of farms and not Gnodes
farm_names=[]
#SCHEDULER.every '10s' do
  DateToday=Time.now
  DateOneHour=Time.now-(60*60)
  #hash to collect all of the data from parsed JSON
    nodes = {}
    
    #given tokens for an account
list_of_glocations=['54','212','204']

  for x in list_of_glocations do
    #Next 4 lines used to get and parse json
    token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id="+x+"&token=2uaHJ8UzbxxFhzr5w9s5&last_configured_at=2015-07-20T16%3A37%3A30.176Z"
    resp = Net::HTTP.get_response(URI.parse(token_source))
    data = resp.body
    result=JSON.parse(data)
    
    #take a random item in the given items placements and get its ID
    items=result['configuration']['placements'].values
    #used a random placement to get the right ID
    random=items[rand(items.length)]
    names=random['glocation_id']
    
    #get the right farm name for the current list of gnodes
    for used in result['configuration']['glocations']
      if used['id']==names
        farm_names.insert(0,used['name'])
        nodes[used['name']]=used['name']
      end
    end
    
    #add all of the gnodes to nodes along with their last reported time under the right farm name
    for name in result['configuration']['placements'] do
      thing=name[1]
      display_name=thing['display_name']
      if thing["gproduct_type"]=="Glink"
        nodes[display_name]=thing["last_heartbeat"]
      else 
        nodes[display_name]=thing["last_reported_at"]
      end 
    end
  end

  #made a new hash for the arrays of farm names and nodes
  farms={}
  for key in nodes do
    #if it is a farm name create a new array and make the key the farm name
    if farm_names.include?(key[1])
      currentFarm=[]
      farms[key]=currentFarm
    else
      #else it is a gnode, and it is placed. (if not placed it wil be nil)
      if key[1]!=nil
        key[1]=Time.parse(key[1])
        currentFarm.insert(0,key)
      end
    end
  end
  #final hash used to compile all of the finalized data that has been sorted
  final1={}  
  for key in farms do
    #make a fresh hash for each array from farms to be sorted by time
    final={}
    key1= key[1]
    key0=key[0]
    
    #the format needed for the send_event method. other options are "status",
    #where you can have a warning or danger message customized (havent been
    # able to get it to work), and (more to come as i find them)
    final[key0[0]]={label: "Farm Name", value:key0[1]}
    
      for x in key1 do
        temp=Time.at(x[1]).to_datetime()
        toFinal=x[0]
        if (DateToday.to_datetime()-temp)>(DateToday.to_datetime()-DateOneHour.to_datetime())
          status='warning'
        else
          status='danger'
        end
        
        final[toFinal] = { label: toFinal, value: x[1], status:status }
      end
      
      #Brad wrote this to sort all of the items by time. The names of the farms
      #were given the oldest possible time so they'd be first in the list
      one = final.sort_by{|_k,xq| xq[:value].is_a?(String) ? Time.at(0) : xq[:value]}.to_h
      
      #merge the sorted hash to the final hash
      final1=one.merge(final1)
  end
  #send the event with the ID farm
  send_event('farm', { items: final1.values })
#end
