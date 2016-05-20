require 'sinatra'
require 'httparty'
require 'nokogiri'
require 'json'

get '/' do
  resp = HTTParty.get("http://bh.buscms.com/api/REST/html/departureboard.aspx?callback=BusCms.widgets[%27widgetLookupDepartures_stop-departureboardCanvas%27].loadStopTimes_callback&_=&clientid=BrightonBuses&sourcetype=siri&stopid=7731&format=jsonp&servicenamefilter=")
  html = resp[91..-4]
  html.gsub!("\\\"", "\"")

  buses = ""
  Nokogiri::HTML(html).css("tr[class='rowServiceDeparture']").each_with_index do |row, i|
    buses += row.css("td[class='colServiceName']").text
    buses += " (" + row.css("td")[1]["title"] + ")"
    buses += ": "
    buses += row.css("td[data-departuretime]").text
    buses += " (" + row.css("td")[2]["data-departuretime"] + ")\n"
  end
  respond_with buses
end

get '/search/:name' do
  stop_name = params['name'].gsub(" ", "+")
  base_url = "http://bh.buscms.com/api/rest/ent/stop.aspx?callback=jsonp1463771285418&clientid=BrightonBuses&method=search&format=jsonp&q="
  resp = HTTParty.get(base_url + stop_name)
  respond_with resp
end

def respond_with message
  content_type :json
  {response_type: "in_channel", text: message}.to_json
end

error Sinatra::NotFound do
  content_type 'text/plain'
  [404, 'Not Found']
end
