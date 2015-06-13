require 'time'
require 'nokogiri'
require 'open-uri'
require 'xpath'
require 'rufus-scheduler'

# # Change the refresh times if needed
# # Updates list of trains arriving in the next 5 minutes (TIME) every 1 minute (UPDATE).
# # Displays a particular train/stop combination data for 3 seconds (DISPLAY) before cycling to another
UPDATE = '1m'
TIME = 10 # Note that this is an integer, not a string (represents minutes)
DISPLAY = '10s'

# Displays train/stop info, and cycles through the different data 
SCHEDULER.every DISPLAY, :first_in => '5s' do |job|
	
	
	begin
		@doc = Nokogiri::HTML(open("http://realtime.mbta.com/developer/api/v2/predictionsbystop?api_key=wEpEc-TOuUWeNsxz1DwzQw&stop=70010&format=xml"))
		ob1=parseTime(@doc,1)
		ob2=parseTime(@doc,2)
		ob3=parseTime(@doc,3)
		obn1 = getDir(@doc,1)	
		obn2 = getDir(@doc,2)	
		obn3 = getDir(@doc,3)	

		@ddoc=Nokogiri::HTML(open("http://realtime.mbta.com/developer/api/v2/predictionsbystop?api_key=wEpEc-TOuUWeNsxz1DwzQw&stop=70011&format=xml"))
		ib1=parseTime(@ddoc,1)
		ib2=parseTime(@ddoc,2)
		ib3=parseTime(@ddoc,3)
		ibn1 = getDir(@ddoc,1)
		ibn2 = getDir(@ddoc,2)
		ibn3 = getDir(@ddoc,3)
		file = open("http://realtime.mbta.com/developer/api/v2/predictionsbystop?api_key=wEpEc-TOuUWeNsxz1DwzQw&stop=Ruggles&format=xml")
		@crdoc=Nokogiri::HTML(file)	
		cr1=parseTimeCR(@crdoc,1)
		cr2=parseTimeCR(@crdoc,2)
		crn1 = getDirCR(@crdoc,1)
		crn2 = getDirCR(@crdoc,2)
		send_event('mbta', {obn1: obn1, obn2: obn2, obn3: obn3, ob1: ob1, ob2: ob2, ob3: ob3,ibn1: ibn1, ibn2: ibn2, ibn3: ibn3, ib1: ib1, ib2: ib2, ib3: ib3, cr1: cr1, cr2: cr2, crn1: crn1, crn2: crn2})
	rescue OpenURI::HTTPError => e
		if e.message.include? "404"
			#Train info not avail
		else
			raise e
		end
	end
end


#hacky way to do it but probs not more than 4 upcoming trains, could be fixed w.for loop
def parseTime(doc,pos)
	t1=doc.xpath("number(//trip["+pos.to_s+"]/@pre_away)")
	if !t1.nan?
		if t1.to_i<60
			return "ARR"
		elsif t1.to_i > 20*60
			return ""
		elsif (t1.to_i/60)<6 && (t1.to_i/60)>=3
			return (t1.to_i/60).to_s + "m "+(t1%60).to_i.to_s  + "s"
		else
			return (t1.to_i/60).to_s + "m "
		end
	else
	tm=""
	end
   return tm
end

def getDir(doc,pos)
	t1=doc.xpath("number(//trip["+pos.to_s+"]/@pre_away)")
	if t1.nan?
		return ""
	elsif t1.to_i > 20*60
		return ""
	else
		return doc.xpath("string(//trip["+pos.to_s+"]/@trip_headsign)")
	end
end

#commuter rail versions
def parseTimeCR(doc,pos)
	t1=doc.xpath("number(//direction[@direction_id=1]/trip["+pos.to_s+"]/@pre_away)")
	if !t1.nan?
		if t1.to_i<60
			return "ARR"
		elsif t1.to_i > 60*60  #dont show >1hr
			return ""
		else
			return (t1.to_i/60).to_s + "m "
		end
	else
	tm=""
	end
   return tm
end

def getDirCR(doc,pos)
	t1=doc.xpath("number(//direction[@direction_id=1]/trip["+pos.to_s+"]/@pre_away)")
	if t1.nan?
		return ""
	elsif t1.to_i > 60*60 #don't show over 1hr
		return ""
	else
		return doc.xpath("string(//direction[@direction_id=1]/trip["+pos.to_s+"]/@trip_headsign)")
	end
end
