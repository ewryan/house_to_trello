require 'trello'

class TrelloService
include Trello

  def initialize config
    @config = config

    Trello.configure do |t_config|
      t_config.developer_public_key = @config["trello"]["api_key"]
      t_config.member_token = @config["trello"]["token"]
    end

    eric = Member.find(@config["trello"]["member_name"])
    board = eric.boards.select {|b| b.name==@config["trello"]["board"]}.first
    @list = board.lists.select {|l| l.name==@config["trello"]["list"]}.first
    @existing_cards = board.cards.map {|c| c.name}.to_set
  end

  def create_if_doesnt_exist hash
    # Create Trello Card
    if @existing_cards.include?(hash[:key])
    	puts "skipping '#{hash[:key]} because Trello Card already exists"
    	return nil
    else
      card = Card.create(
        name: hash[:key],
        list_id: @list.id,
        desc: "#{hash[:description]}\r\n #{hash[:url]}"
      )
      card.add_attachment(hash[:img])
      return card
    end

  end
end