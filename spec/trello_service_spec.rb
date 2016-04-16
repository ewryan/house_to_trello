require "spec_helper"
require 'support/vcr_setup'
require "lib/models/trello_service"

describe TrelloService do
  let(:trello) {TrelloService.new(config)}

  describe "#run" do
    it "creates cards" do

      VCR.use_cassette('trello_create_with_attachments') do
        result_hash = {
          street: 'Testing 123 Lane',
          city: "Wombatville",
          state: "DE",
          zip: "19973",
          price: "$123,000",
          img: "http://p.iresis.com/PropPhoto/015/048/015048699_640x480.jpg",
          url: "http://www.iresis.com/cwa/mysite/inbox/details?lgid=23634503&lid=1086715",
          description: "\r\nTrash bird factory\r\n",
          key: "$123,000 - Testing 123 Lane Wombatville DE 19973",
          status: "For Sale"
        }
        card = trello.create_if_doesnt_exist(result_hash)

        expect(card.name).to eq(result_hash[:key])
        expect(card.desc).to eq("#{result_hash[:description]}\r\n #{result_hash[:url]}")
        expect(card.attachments.size).to eq(1)
        expect(card.attachments.first.url).to include('015048699_640x480.jpg')
      end
    end
  end
end
