require 'sinatra'
require 'httparty'
require 'nokogiri'

get '/' do
  resp = HTTParty.get("http://bh.buscms.com/api/REST/html/departureboard.aspx?callback=BusCms.widgets[%27widgetLookupDepartures_stop-departureboardCanvas%27].loadStopTimes_callback&_=1463155378395&clientid=BrightonBuses&sourcetype=siri&stopid=7731&format=jsonp&servicenamefilter=")
  html = resp[91..-4]
  html.gsub!("\\\"", "\"")

  output = ""
  Nokogiri::HTML(html).css("tr[class='rowServiceDeparture']").each do |row|
    output += "<p>" + row.css("td[class='colServiceName']").text
    output += " (-> " + row.css("td")[1]["title"] + ")"
    output += ": "
    output += row.css("td[data-departuretime]").text
    output += " (" + row.css("td")[2]["data-departuretime"] + ")" + "</p>"
  end
  output
end
