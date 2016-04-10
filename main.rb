require 'bundler'
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

#Load Config
config = YAML::load_file(File.join(__dir__, 'config.yml'))
root_page_url = config['web']['url']

mechanize_client = Mechanize.new
mechanize_client.user_agent_alias = "Mac Firefox"
twilio = TwilioService.new(config)
trello = TrelloService.new(config)

detail_page_links = IRESRootCrawler.new(config, mechanize_client, root_page_url).run

detail_page_links.each do |page|
	detail_crawler = IRESDetailCrawler.new(config, mechanize_client, page)
	result_hash = detail_crawler.run
	created_card = trello.create_if_doesnt_exist(result_hash)
	twilio.send_sms(result_hash, created_card) if created_card
end