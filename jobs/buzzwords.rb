require 'net/http'
require 'time'

    nodes = {}
list_of_glocations=['54']
  for x in list_of_glocations do
    token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id="+x+"&token=2uaHJ8UzbxxFhzr5w9s5&last_configured_at=2015-07-20T16%3A37%3A30.176Z"
    resp = Net::HTTP.get_response(URI.parse(token_source))
    data = resp.body
    result=JSON.parse(data)
    for name in result['configuration']['placements'] do
      thing=name[1]
      display_name=thing['display_name']
      if thing["gproduct_type"]=="Glink"
        nodes[display_name]=thing["last_heartbeat"]
      else 
        nodes[display_name]=thing["last_reported_at"]
      end
    end
    nodes["name"]=result["configuration"]["glocations"][0]["name"]
  end
  


farm_counts={}
thing=nodes["name"]
farm_counts["Farm Name"] = {label:"Farm Name", value: thing}
    send_event('buzzwords', { items: farm_counts.values })
nodes.delete("name")
  
#SCHEDULER.every '2s' do
  for key in nodes do
    key[1]=Time.parse(key[1])
    farm_counts[key[0]] = {label:key[0], value: key[1]}
  end
  farm_counts = farm_counts.sort_by {|_k,v| v[:value].is_a?(String) ? Time.at(0) : v[:value]}.to_h
  send_event('buzzwords', { items: farm_counts.values })
#end


#buzzword_counts[random_buzzword] = { label: random_buzzword, value: (buzzword_counts[random_buzzword][:value] + 1) % 30 }
#
#glove={ label: "Yes", value: 555 }
#send_event('buzzwords', { items: glove.values })
#
#
#require 'pry'; binding.pry
#
#send_event('buzzwords', { items: glove.values })
#
#send_event('buzzwords', { items: buzzword_counts.values })
#
#
#SCHEDULER.every '10s' do
#  random_buzzword = buzzwords.sample
#  buzzword_counts[random_buzzword] = { label: random_buzzword, value: (buzzword_counts[random_buzzword][:value] + 1) % 30 }
#  require 'pry'; binding.pry
#  
#  send_event('buzzwords', { items: buzzword_counts.values })
#end