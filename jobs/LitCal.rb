require 'httparty'
require 'nokogiri'
require 'csv'
require 'rufus-scheduler'
require 'time'

SCHEDULER.every '60s', :first_in => 0 do |job|
	page4 = HTTParty.get('http://www.romcal.net/output/'+Date.today.strftime("%Y")+'.lst')
	page = HTTParty.get('http://calapi.inadiutorium.cz/api/v0/en/calendars/default/'+Time.now.strftime("%Y/%m/%d"))
	page2 = HTTParty.get('http://www.catholic.org/saints/sofd.php')
	link3 = Nokogiri::HTML(page2).xpath('//div[@id="saintsSofd"]/h3/a/@href')[0]
	saint_name =  Nokogiri::HTML(page2).css("#saintsSofd").css("h3").css("a").first.text
	page3 = HTTParty.get('http://catholic.org'+link3)
	saint_image = 'http://catholic.org' + (Nokogiri::HTML(page3).xpath('//div[@id="saintImage"]/img/@src')).to_s
	day_string = (page4.split(Time.now.strftime("%a %b %e, %Y:"))[1]).split("\n")[0]
	rank = day_string.split(":")[0]
	if rank=="Opt. Mem."
		rank = "Optional Memorial"
	elsif rank =="Commem.  "
		rank = "Commemeration"
	end
	weekday = Time.now.strftime("%A")
	title = day_string.split(":")[2].gsub(';','\n')
	if title.include? 'Week'
		title = ""
	end
	saint_name =  Nokogiri::HTML(page2).css("#saintsSofd").css("h3").css("a").first.text
	season = page['season'].to_s.capitalize

	color = day_string.split(":")[1].downcase.strip

	suffix = "th"
	if page['season_week']==1
		suffix="st"
	elsif page['season_week']==2
		suffix="nd"
	elsif page['season_week']==3
		suffix="rd"
	end

	week = page['season_week'].to_s+suffix+" week of "+season
	
	send_event('litcal', { color: color, weekday:weekday, title:title, week:week, rank:rank, saint:saint_name, saint_image:saint_image} )
end