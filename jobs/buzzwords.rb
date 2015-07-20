require 'net/http'

    nodes = {}
list_of_glocations=['54','212','204']
  for x in list_of_glocations do
    token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id="+x+"&token=2uaHJ8UzbxxFhzr5w9s5&last_configured_at=2015-07-20T16%3A37%3A30.176Z"
    resp = Net::HTTP.get_response(URI.parse(token_source))
    data = resp.body
    result=JSON.parse(data)
    #print (result['configuration']['placements'])
    for name in result['configuration']['placements'] do
      print (name[1])
      thing2=name[1]
      if thing2["gproduct_type"]=="Glink"
        nodes[thing2]['display_name']=gnode["last_heartbeat"]
      else 
        nodes[thing2]['display_name']=gnode["last_reported_at"]
      end
    end
  end

SCHEDULER.every '5s' do
  for key in nodes
    final = { label: key[0], value: nodes[key][0] }
    send_event('buzzwords', { items: final.values })
  end
end
