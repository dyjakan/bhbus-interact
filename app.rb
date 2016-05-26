require 'sinatra'
require 'httparty'
require 'nokogiri'
require 'json'

get '/times/:name' do
  base_url = "http://bh.buscms.com/api/REST/html/departureboard.aspx?clientid=BrightonBuses&sourcetype=siri&format=jsonp&stopid=7731"
  response = HTTParty.get(base_url).parsed_response
  response.gsub!("\\\"", "\"")

  bus_list = ""
  Nokogiri::HTML(response).css("tr[class='rowServiceDeparture']").each_with_index do |row, i|
    bus_list += row.css("td[class='colServiceName']").text
    bus_list += " (" + row.css("td")[1]["title"] + ")"
    bus_list += ": "
    bus_list += row.css("td[data-departuretime]").text
    bus_list += " (" + row.css("td")[2]["data-departuretime"] + ")\n"
  end
  respond_with bus_list
end

get '/stops/:name' do
  stops = get_stops params['name'].gsub(" ", "+")
  "#{stops}"
end

def get_stops(name)
  base_url = "http://bh.buscms.com/api/rest/ent/stop.aspx?clientid=BrightonBuses&method=search&format=jsonp&q="
  HTTParty.get(base_url + name).parsed_response
end

def respond_with(message)
  content_type :json
  {text: message}.to_json
end

error Sinatra::NotFound do
  content_type 'text/plain'
  [404, 'Method Not Found']
end
