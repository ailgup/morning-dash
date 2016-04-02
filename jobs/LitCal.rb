require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'csv'

page = HTTParty.get('http://calapi.inadiutorium.cz/api/v0/en/calendars/general-la/today')
page2 = HTTParty.get('http://www.catholic.org/saints/sofd.php')
page3 = HTTParty.get('http://www.santiebeati.it/ilsantodelgiorno.txt')
page3=(page3.split("src=\"")[1]).split("\"")[0]


saint_name =  Nokogiri::HTML(page2).css("#saintsSofd").css("h3").css("a").first.text
weekday = page['weekday'].to_s.capitalize
season = page['season'].to_s.capitalize
rank = page['rank'].to_s.capitalize
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
saint_name =  Nokogiri::HTML(page2).css("#saintsSofd").css("h3").css("a").first.text
saint_title= ""
saint_image= ""
#optional memorials
if page['celebrations'].length>1 && page['celebrations'][0].title==""
	saint_name = page['celebrations'][1]['title'].split(",")[0]
	if page['celebrations'][1]['title'].include? ','
		saint_title= page['celebrations'][1]['title'].split(",")[1]
	end
	send_event( 'lit_cal', {title: "Optional Memorial", saint_name: progress_items} )
end

color="style: { color:"+color
week = page['season_week'].to_s+title+" week of "+season
send_event('LitCal', { color: color, weekday:weekday, week:week, rank:rank, saint:saint_name } )
