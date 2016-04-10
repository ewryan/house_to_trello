require 'bundler'
require 'mechanize'
require 'awesome_print'
require 'trello'
require 'yaml'

config = YAML::load_file(File.join(__dir__, 'config.yml'))

trello_api_key = config["trello"]["api_key"]
trello_token = config["trello"]["token"]

include Trello

Trello.configure do |config|
  config.developer_public_key = trello_api_key 
  config.member_token = trello_token 
end

eric = Member.find(config["trello"]["member_name"])

board = eric.boards.select {|b| b.name==config["trello"]["board"]}.first
list = board.lists.select {|l| l.name==config["trello"]["list"]}.first
@existing_cards = board.cards.map {|c| c.name}.to_set


m = Mechanize.new
m.user_agent_alias = "Mac Firefox"
page = m.get(config["web"]["url"])

form = page.forms.first

form['loginName'] = config["web"]["username"]
form['password'] = config["web"]["password"]

page = form.submit

raw_results = page.search('div.view-details-link-ct a')

raw_results.each do |result|
	href = result.attr('href')
	details_page = m.get "http://www.iresis.com#{href}"
    # ap details_page 

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

		card = Card.create(
			name: key, 
			list_id: list.id,
			desc: description 
		)
		card.add_attachment(img)
	end

	break
end

#TODO
# production