require "spec_helper"
require 'support/vcr_setup'
require "lib/models/ires_detail_crawler"


describe IRESDetailCrawler do
  let(:client) {IRESDetailCrawler.new config, Mechanize.new, "http://www.iresis.com/cwa/mysite/inbox/details?lgid=23634503&lid=1086715"}

  def node_matches key, value, cassette
    VCR.use_cassette(cassette) do
      result = client.run
      expect(result[key]).to eq(value)
    end
  end

  cassettes = ['details/lgid=23634503&lid=1086715']

  cassettes.each do |cassette|
    describe "#run" do
      it "extracts street" do
        node_matches :street, "802 W Dahlia Ct", cassette
      end

      it "extracts city" do
        node_matches :city, "Louisville", cassette
      end
    end
  end
end
