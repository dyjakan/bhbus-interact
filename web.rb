require 'sinatra'
require 'httparty'
require 'nokogiri'
require 'json'

# get '/' do
  resp = HTTParty.get("http://bh.buscms.com/api/REST/html/departureboard.aspx?callback=BusCms.widgets[%27widgetLookupDepartures_stop-departureboardCanvas%27].loadStopTimes_callback&_=1463155378395&clientid=BrightonBuses&sourcetype=siri&stopid=7731&format=jsonp&servicenamefilter=")
  html = resp[91..-4]
  html.gsub!("\\\"", "\"")


  output = {response_type: "in_channel"}
  line = ""
  attachments = []
  Nokogiri::HTML(html).css("tr[class='rowServiceDeparture']").each_with_index do |row, i|
    line += row.css("td[class='colServiceName']").text
    line += " (" + row.css("td")[1]["title"] + ")"
    line += ": "
    line += row.css("td[data-departuretime]").text
    line += " (" + row.css("td")[2]["data-departuretime"] + ")"
    attachments << {text: line}
    line = ""
  end
  output["attachments"] = attachments
  output.to_json
end
