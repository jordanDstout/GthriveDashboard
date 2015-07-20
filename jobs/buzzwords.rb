require 'net/http'

    nodes = {}
list_of_glocations=['54','212','204']
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
  end
  
  
  
  
SCHEDULER.every '2s' do
  for key in nodes do
    print (key[0])
    print (key[1])
    glove={ label: key[0], value: key[1] }
    send_event('buzzwords', { items:glove.values })
  end
end
