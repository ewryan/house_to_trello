require 'mechanize'
require 'awesome_print'
require 'yaml'
require 'twilio-ruby'


class IRESRootCrawler

  def initialize config, mechanize_client, url
    @config = config
    @url = url
    @m = mechanize_client
  end

  def run
    #Login to root page
    page = @m.get(@url)
    form = page.forms.first
    form['loginName'] = @config["web"]["username"]
    form['password'] = @config["web"]["password"]
    page = form.submit

    #Gather all results on first page
    results = page.search('div.view-details-link-ct a')
    return results.map {|element| "http://www.iresis.com#{element.attr('href')}"}
  end
end
