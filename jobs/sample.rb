 require 'net/http'
   source = "https://secure.gthrive.com/api/client/v2/gserver_version.json?token=''"
   resp = Net::HTTP.get_response(URI.parse(source))
   data = resp.body
   result=JSON.parse(data)
   result=result["data"]["version"]
   current_valuation = 0
   
   
   
   
  
current_karma = 0
SCHEDULER.every '2s' do
  source = "https://secure.gthrive.com/api/client/v2/gserver_version.json?token=''"
  resp = Net::HTTP.get_response(URI.parse(source))
  data = resp.body
  result=JSON.parse(data)
  result=result["data"]["version"]
  current_valuation = 0
  
  
  
  
  list_of_glocations=[54,212,204]
  for x in list_of_glocations do
    token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id="+x+"&token=2uaHJ8UzbxxFhzr5w9s5&last_configured_at=2015-07-20T16%3A37%3A30.176Z"
    resp2 = Net::HTTP.get_response(URI.parse(token_source))
    data = resp2.body
    result2=JSON.parse(data2)
    result2["placements"]   
   
  last_valuation = current_valuation
  last_karma     = current_karma
  current_valuation = result
  current_karma     = rand(200000)

  send_event('valuation', { current: current_valuation, last: last_valuation })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: rand(100) })
end