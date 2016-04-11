require "spec_helper"
require 'support/vcr_setup'
require "lib/models/ires_root_crawler"


describe IRESRootCrawler do
  let(:client) {IRESRootCrawler.new config, Mechanize.new, config['web']['url']}

  describe "#run" do
    it "processes URLs that contain root URL" do
      root_url = "/cwa/mysite/inbox/details"

      VCR.use_cassette('root_page') do
        results = client.run
        results.each do |result|
          expect(result).to include(root_url)
        end
      end
    end
  end
end
