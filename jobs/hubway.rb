require 'time'
require 'nokogiri'
require 'open-uri'
require 'xpath'
require 'rufus-scheduler'


SCHEDULER.every '30s', :first_in => 0 do |job|

	@doc = Nokogiri::HTML(open("http://www.thehubway.com/data/stations/bikeStations.xml"))
	progress_items = [{ name: "Ruggles", progress: percAvail(@doc,"Ruggles"), value: stringAvail(@doc,"Ruggles") }, { name: "North Lot", progress: percAvail(@doc,"North Parking Lot") , value:stringAvail(@doc,"North Parking Lot") }, { name: "Mass Ave.", progress: percAvail(@doc,"Columbus Ave. at Mass. Ave.") , value:stringAvail(@doc,"Columbus Ave. at Mass. Ave.") }, { name: "Sleeper St.", progress: percAvail(@doc,"Congress / Sleeper"), value:stringAvail(@doc,"Congress / Sleeper")  }, { name: "South Station", progress: percAvail(@doc,"South Station - 700 Atlantic Ave.") , value:stringAvail(@doc,"South Station - 700 Atlantic Ave.") }]
	send_event( 'progress_bars', {title: "Hubway", progress_items: progress_items} )

end

def percAvail(doc,nameCheck)
	max = doc.xpath("count(//station)")
	for counter in 0..max
		if doc.xpath("string(//station[#{counter}]/name)").include? nameCheck 
			numBikes = doc.xpath("number(//station[#{counter}]/nbbikes)")
			numEmpty = doc.xpath("number(//station[#{counter}]/nbemptydocks)")
			return (numBikes/(numBikes+numEmpty))*100
		end
	end
	puts "Error with Hubway Station ID " +nameCheck
	return "error"
end

def stringAvail(doc,nameCheck)
	max = doc.xpath("count(//station)")
	for counter in 0..max
		if doc.xpath("string(//station[#{counter}]/name)").include? nameCheck 
			numBikes = doc.xpath("number(//station[#{counter}]/nbbikes)").to_i
			numEmpty = doc.xpath("number(//station[#{counter}]/nbemptydocks)").to_i
			str= numBikes.to_s+"/"+(numBikes+numEmpty).to_s
			return str
		end
	end
	puts "Error with Hubway Station ID " +nameCheck
	return "error"
end