require 'sinatra'
require 'httparty'
require 'nokogiri'
require 'json'

post '/' do
  puts params
  respond_with "tbc"
end

get '/times/:name' do
  get_times_list params['name'].gsub(" ", "+")
end

get '/stops/:name' do
  get_stops_list params['name'].gsub(" ", "+")
end

error Sinatra::NotFound do
  content_type 'text/plain'
  [404, 'Method Not Found']
end

helpers do
  def get_times_list(name)
    stops = get_stops name
    return respond_with "Stop does not exist." if stops["result"].size == 0
    return respond_with "There are multiple bus stops with this name. Please, use `stops` command to list them all." if stops["result"].size > 1

    stop_id = stops["result"][0]["stopId"]
    url = "http://bh.buscms.com/api/REST/html/departureboard.aspx?clientid=BrightonBuses&sourcetype=siri&format=jsonp&stopid=#{stop_id}"
    timetable = HTTParty.get(url).parsed_response
    timetable.gsub!("\\\"", "\"")

    bus_list = ""
    Nokogiri::HTML(timetable).css("tr[class='rowServiceDeparture']").each_with_index do |row, i|
      bus_list += row.css("td[class='colServiceName']").text
      bus_list += " (" + row.css("td")[1]["title"] + ")"
      bus_list += ": "
      bus_list += row.css("td[data-departuretime]").text
      bus_list += " (" + row.css("td")[2]["data-departuretime"] + ")\n"
    end

    respond_with bus_list
  end

  def get_stops_list(name)
    stops = get_stops name
    return respond_with "Stop does not exist." if stops["result"].size == 0

    stops_list = ""
    stops["result"].each { |stop| stops_list += stop["stopName"].gsub(")", "") + " (NAPTAN: #{stop["NaptanCode"]})\n" }

    respond_with stops_list
  end

  def get_stops(name)
    url = "http://bh.buscms.com/api/rest/ent/stop.aspx?clientid=BrightonBuses&method=search&format=jsonp&q=#{name}"
    stops = HTTParty.get(url).parsed_response
    stops.gsub!("(", "")
    stops.gsub!(");", "")
    JSON.parse(stops)
  end

  def respond_with(message)
    content_type :json
    {text: message, mrkdwn_in: "text"}.to_json
  end
end
