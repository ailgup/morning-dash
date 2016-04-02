require 'net/http'
require 'net/https'
require 'uri'
require 'json'

key             = URI::encode('emfzpfv8dcee2dkkubqantzg')
locations       = []
locations << { name: "CyPhy via Storrow", location: URI::encode('42.33716720443085,-71.08634632133482:circle(42.348449,-71.072096,100):42.57545873043469,-70.97465425729752') }
locations << { name: "CyPhy via 93", location: URI::encode('42.33716720443085,-71.08634632133482:circle(42.335263,-71.06687665,100):42.57545873043469,-70.97465425729752') }
locations << { name: "NEU via Rt.1", location: URI::encode('42.57545873043469,-70.97465425729752:circle(42.384754,-71.047544,100):42.33716720443085,-71.08634632133482') }
locations << { name: "NEU via I-95", location: URI::encode('42.57545873043469,-70.97465425729752:circle(42.390849,-71.083114,100):42.33716720443085,-71.08634632133482') }
locations << { name: "Townsend", location: URI::encode('42.33716720443085,-71.08634632133482:42.62207049,-71.67189181') }


SCHEDULER.every '10m', :first_in => '15s' do |job|
    routes = []

    # pull data
    locations.each do |location|
        uri = URI.parse("https://api.tomtom.com/routing/1/calculateRoute/#{location[:location]}/json?routeType=fastest&traffic=true&travelMode=car&key=#{key}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        routes << { name: location[:name], location: location[:location], route: JSON.parse(response.body)["routes"][0] }
    end

    # find winner
    if routes
        routes.sort! { |route1, route2| route2[:route]["summary"]["travelTimeInSeconds"] <=> route1[:route]["summary"]["travelTimeInSeconds"] }
        routes.map! do |r|
            { name: r[:name],
                time: seconds_in_words(r[:route]["summary"]["travelTimeInSeconds"].to_i),
                road: delay(r[:route]["summary"]["trafficDelayInSeconds"])}
        end
    end

    # send event
  send_event('tomtom', { results: routes } )
end

def seconds_in_words(secs)
    m, s = secs.divmod(60)
    h, m = m.divmod(60)

    plural_hours = if h > 1 then "s" else "" end
    plural_minutes = if m > 1 then "s" else "" end

    if secs >= 3600
        "#{h} hour#{plural_hours}, #{m} min#{plural_minutes}"
    else
        "#{m} min#{plural_minutes}"
    end
end

def delay(delay_seconds)
    m, s = delay_seconds.divmod(60)
    h, m = m.divmod(60)

    if delay_seconds >= 60
        "#{m} min delay"
    elsif delay_seconds == 0
        ""
    else
        "#{s} sec delay"
    end
end