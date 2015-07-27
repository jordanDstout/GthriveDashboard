require 'net/http'
require 'time'

farm_names=[]
SCHEDULER.every '5s' do
    nodes = {}
    
list_of_glocations=['54','212','204']
z=0
  for x in list_of_glocations do
    token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id="+x+"&token=2uaHJ8UzbxxFhzr5w9s5&last_configured_at=2015-07-20T16%3A37%3A30.176Z"
    resp = Net::HTTP.get_response(URI.parse(token_source))
    data = resp.body
    result=JSON.parse(data)
    items=result['configuration']['placements'].values
    random=items[rand(items.length)]
    names=random['glocation_id']
    for used in result['configuration']['glocations']
      if used['id']==names
        farm_names.insert(0,used['name'])
        nodes[used['name']]=used['name']
      end
    end
    for name in result['configuration']['placements'] do
      thing=name[1]
      display_name=thing['display_name']
      if thing["gproduct_type"]=="Glink"
        nodes[display_name]=thing["last_heartbeat"]
      else 
        nodes[display_name]=thing["last_reported_at"]
      end 
    end
    z=z+1
  end


farms={}
  for key in nodes do
    if farm_names.include?(key[1])
      currentFarm=[]
      farms[key]=currentFarm
      currentName=key
    else
      if key[1]!=nil
        key[1]=Time.parse(key[1])
        currentFarm.insert(0,key)
      end
      
      
    end
    farms[currentName]=currentFarm
  end
  final1={}  
  for key in farms
    final={}
    key1= key[1]
    key0=key[0]
    final[key0[0]]={label: "Farm Name", value:key0[1]}
    
      for x in key1
        toFinal=x[0]
        final[toFinal] = { label: toFinal, value: x[1], status: 'danger' }
      end
      one = final.sort_by{|_k,x| x[:value].is_a?(String) ? Time.at(0) : x[:value]}.to_h
      final1=one.merge(final1)
  end
  
  #if value > 50 && value < 75
  #status = 'warning'
  #
  #send_event('event',  { value: value, status: status } )
  
  print final1.values
  
  send_event('farm', { items: final1.values })
  
end

