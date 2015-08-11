require 'net/http'
require 'time'
require 'json'



#Issues: This program is pretty slow. I mark places where i think it is especially bad.
#i wanted to try to change the text color which is why i have the commented out
#'status' part of the code.
#I loop through 3 separate times but I think i may be able to do it all in one.
# The reason i did it the way i did was for readability purposes. Each loop has a clearly defined
# job and i mark each variable


#array used to track which parts of the parsed data are names of farms and not Gnodes
farm_names=[]
list_of_glocations=[]
token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id=212&token=S_zwxQKD6xWqxMLGx9ks&last_configured_at=2015-06-26T23:25:49.962Z"
    resp = Net::HTTP.get_response(URI.parse(token_source))
    data = resp.body
    result=JSON.parse(data)
    config=result['configuration']
    for placementID in config['glocations']
      list_of_glocations.insert(0,placementID['id'])
    end
    
SCHEDULER.every '10s' do
  DateToday=Time.now
  DateOneHour=Time.now.to_i-(60*60)
  #hash to collect all of the data from parsed JSON
    nodes = {}
    

  for x in list_of_glocations do
    x=x.to_s
    #Next 4 lines used to get and parse json
    token_source = "https://secure.gthrive.com/api/client/v2/gnodes.json?glocation_id="+x+"&token=S_zwxQKD6xWqxMLGx9ks&last_configured_at=2015-06-26T23:25:49.962Z"
    resp = Net::HTTP.get_response(URI.parse(token_source))
    data = resp.body
    result=JSON.parse(data)
    if result['data'].length==0
      next
    end
    

    
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


  #I think i can combine this part and the previous part. This would save an extra
  #loop through all of the placements
  
  #made a new hash for the arrays of farm names and nodes
  farms={}
  for key in nodes do
    #if it is a farm name create a new array in farms (hash) and make the key the farm name
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
  #this deletes any farms that have no placements (such as Sadie)
  for deleter in farms do
    if deleter[1].length==0
      farms.delete(deleter[0])
    end
  end
  for key in farms do
    
    #make a fresh hash for each array from farms to be sorted by time
    final={}
    
    key0=key[0]
    key1= key[1]
    
    #the format needed for the send_event method. other options are "status",
    #where you can have a warning or danger message customized (havent been
    # able to get it to work), and (more to come as i find them)
    final[key0[0]]={label: "----FARM NAME----", value:key0[1]}
   
   
      ##Set the status for each item in th
      for x in key1 do
        toFinal=x[0]
        final[toFinal] = { label: toFinal, value: x[1]}
      end
      
      #Brad wrote this to sort all of the items by time. The names of the farms
      #were given the oldest possible time so they'd be first in the list
      one = final.sort_by{|_k,xq| xq[:value].is_a?(String) ? Time.at(0) : xq[:value]}.to_h
      
      #merge the sorted hash to the final hash
    final1=one.merge(final1)

  end
  #send the event with the ID all
  send_event('all', { items: final1.values })
end






#I couldnt get this working but it is used to access the
#DOM directly and change the attributes of individual items


#require 'nokogiri'
#require 'watir-webdriver'

#url='localhost:3030/sampletv'
#url='https://status.io.watchmouse.com/7617'
#
#  b = Watir::Browser.new :phantomjs
#  b.goto(url)

  #d=Nokogiri::HTML(b.html)
  #rows=[]
  #a = d.css(".psp-table").first.css('td').each_slice(5).map{|l| l.join(',').split(',')}.drop(1)
  #console.log(a)

  # a.each do |line|
  #   rows << line[0]
  #   data = {
  #    status: TW_HEALTH_TO_LIGHT[line[1]],
  #    message: line[0]
  #  }
  #  send_event(line[0], data)
  #end