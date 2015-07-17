 require 'net/http'
   source = "https://secure.gthrive.com/api/client/v2/gserver_version.json?token=''"
   resp = Net::HTTP.get_response(URI.parse(source))
   data = resp.body
   result=JSON.parse(data)
   result=result["data"]["version"]
   current_valuation = 0
current_karma = 0
SCHEDULER.every '2s' do
  last_karma     = current_karma
  current_valuation = result
  current_karma     = rand(200000)

  send_event('valuation', { current: current_valuation, last: null })
  send_event('karma', { current: current_karma, last: last_karma })
  send_event('synergy',   { value: rand(100) })
end