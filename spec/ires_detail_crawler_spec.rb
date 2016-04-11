require "spec_helper"
require 'support/vcr_setup'
require "lib/models/ires_detail_crawler"


describe IRESDetailCrawler do
  def node_matches key, value, cassette
    VCR.use_cassette(cassette) do
      result = client.run
      expect(result[key]).to eq(value)
    end
  end

  tests = [
    {
      cassette: 'lgid=23634503&lid=1086715',
      values: {
        street: '802 W Dahlia Ct',
        city: "Louisville",
        state: "CO",
        zip: "80027",
        price: "$659,000",
        img: "http://p.iresis.com/PropPhoto/015/048/015048699_640x480.jpg",
        url: "http://www.iresis.com/cwa/mysite/inbox/details?lgid=23634503&lid=1086715",
        description: "\r\n5 bdrm,3-1/2 bath 2-story with main floor master bdrm across the street from Fireside Elementary.Large rooms everywhere.Spacious kitchen has double ovens, gas range,corian counter tops, loads of cabinets and counter space, island and walk-in pantry.Energy efficient Anderson windows, slate tile entry and lots of hardwood floors.Upstairs has 3-large bdrms + 13x12 loft.Finished bsmt has 5th bdrm,3/4 bath, big rec room, exercise room and work area.Backyard has rear deck, apple tree & kids play area.\r\n",
        key: "$659,000 - 802 W Dahlia Ct Louisville CO 80027"
      }
    }
  ]

  describe "#run" do
    tests.each do |test|      
      let(:client) {IRESDetailCrawler.new config, Mechanize.new, "http://www.iresis.com/cwa/mysite/inbox/details?#{test[:cassette]}"}
      test[:values].each do |key, val|
        it "extracts #{key} for #{test[:cassette]}" do
          node_matches key, val, "details/#{test[:cassette]}"
        end
      end
    end
  end
end
