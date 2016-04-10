require 'bundler'
require 'mechanize'
require 'awesome_print'
require 'trello'
require 'yaml'
require 'twilio-ruby'

include Trello

#Load Config
config = YAML::load_file(File.join(__dir__, 'config.yml'))

#Setup Trello Client
trello_api_key = config["trello"]["api_key"]
trello_token = config["trello"]["token"]

Trello.configure do |config|
  config.developer_public_key = trello_api_key 
  config.member_token = trello_token 
end

#Setup Twilio Client
twilio_account_sid = config["twilio"]["api_key"]
twilio_auth_token = config["twilio"]["token"]		
@twilio_client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token

eric = Member.find(config["trello"]["member_name"])
board = eric.boards.select {|b| b.name==config["trello"]["board"]}.first
list = board.lists.select {|l| l.name==config["trello"]["list"]}.first
@existing_cards = board.cards.map {|c| c.name}.to_set

#Login to root page
m = Mechanize.new
m.user_agent_alias = "Mac Firefox"
page = m.get(config["web"]["url"])
form = page.forms.first
form['loginName'] = config["web"]["username"]
form['password'] = config["web"]["password"]
page = form.submit

#Gather all results on first page
raw_results = page.search('div.view-details-link-ct a')

#Iterate through each result page .. parsing necessary data.
raw_results.each do |result|
	href = result.attr('href')
	details_page = m.get "http://www.iresis.com#{href}"
	street = details_page.search('span.street').text
	city = details_page.search('span.city').text
	state = details_page.search('span.state').text
	zip = details_page.search('span.zip').text
	price = details_page.search('div.overview h3').text
	img = details_page.at_css('img').attr('src')
	url = details_page.uri
	description = details_page.at_css('div.description').text + "\r\n#{url}"

	key = "#{price} - #{street} #{city} #{state} #{zip}"

	if @existing_cards.include?(key)
        puts "skipping '#{key}' .. card already exists"
	else
		puts key
		puts description

		#Create Trello Card
		card = Card.create(
			name: key, 
			list_id: list.id,
			desc: description 
		)
		card.add_attachment(img)

		#Send SMS Message
		config['twilio']['dest_phone_numbers'].each do |dest_phone_number|
			@twilio_client.messages.create(
			  from: config['twilio']['source_phone_number'],
			  to: dest_phone_number,
			  body: "#{key}\n\n#{card.url}"
			)
		end
	end

	break
end