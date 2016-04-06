require 'httparty'
require 'nokogiri'
require 'csv'
require 'rufus-scheduler'
require 'time'

SCHEDULER.every '60s', :first_in => 0 do |job|
	page = HTTParty.get('http://calapi.inadiutorium.cz/api/v0/en/calendars/default/'+Date.today.strftime("%Y/%m/%d"))
	page2 = HTTParty.get('http://www.catholic.org/saints/sofd.php')
	link3 = Nokogiri::HTML(page2).xpath('//div[@id="saintsSofd"]/h3/a/@href')[0]
	saint_name =  Nokogiri::HTML(page2).css("#saintsSofd").css("h3").css("a").first.text
	page3 = HTTParty.get('http://catholic.org'+link3)
	saint_image = 'http://catholic.org' + (Nokogiri::HTML(page3).xpath('//div[@id="saintImage"]/img/@src')).to_s


	saint_name =  Nokogiri::HTML(page2).css("#saintsSofd").css("h3").css("a").first.text
	weekday = page['weekday'].to_s.capitalize
	season = page['season'].to_s.capitalize
	rank = page['celebrations'][0]['rank'].to_s.capitalize
	if rank==""
		rank="Octave of Easter"
	end
	color = page['celebrations'][0]['colour']

	title = "th"
	if page['season_week']==1
		title="st"
	elsif page['season_week']==2
		title="nd"

	elsif page['season_week']==3
		title="rd"
	end

	saint_title= ""
	#optional memorials
	if page['celebrations'].length>1 && page['celebrations'][0].title==""
		saint_name = page['celebrations'][1]['title'].split(",")[0]
		if page['celebrations'][1]['title'].include? ','
			saint_title= page['celebrations'][1]['title'].split(",")[1]
		end
		#send_event( 'LitCal', {title: "Optional Memorial", saint_name: progress_items} )
	end

	color=color
	week = page['season_week'].to_s+title+" week of "+season
	send_event('litcal', { color: color, weekday:weekday, week:week, rank:rank, saint:saint_name, saint_image:saint_image, saint_tite:'Hermit' } )
end