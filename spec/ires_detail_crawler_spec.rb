require "spec_helper"
require 'support/vcr_setup'
require "lib/models/ires_detail_crawler"


describe IRESDetailCrawler do
  let(:client) {IRESDetailCrawler.new config, Mechanize.new, "http://www.iresis.com/cwa/mysite/inbox/details?lgid=23634503&lid=1086715"}

  describe "#run" do
    it "extracts address" do
      VCR.use_cassette('details/lgid=23634503&lid=1086715') do
        result = client.run
        expect(result[:street]).to eq("802 W Dahlia Ct")
      end
    end
  end
end
