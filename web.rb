require 'sinatra'
require 'httparty'
require 'nokogiri'

get '/' do
  resp = HTTParty.get("http://bh.buscms.com/api/REST/html/departureboard.aspx?callback=BusCms.widgets[%27widgetLookupDepartures_stop-departureboardCanvas%27].loadStopTimes_callback&_=1463155378395&clientid=BrightonBuses&sourcetype=siri&stopid=7731&format=jsonp&servicenamefilter=")
  Nokogiri::HTML(resp).css("table")
end
