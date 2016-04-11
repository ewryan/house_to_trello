class IRESDetailCrawler

  def initialize config, mechanize_client, details_url
    @config = config
    @details_url = details_url
    @m = mechanize_client
  end

  def run   
    details_page = @m.get @details_url   
    if details_page.body.include?('loginName') 
      form = details_page.forms.first
      form['loginName'] = @config["web"]["username"]
      form['password'] = @config["web"]["password"]
      details_page = form.submit
    end

    street = details_page.search('span.street').text
    city = details_page.search('span.city').text
    state = details_page.search('span.state').text
    zip = details_page.search('span.zip').text
    price = details_page.search('div.overview h3').text
    img = details_page.at_css('img').attr('src')
    url = details_page.uri
    description = details_page.at_css('div.description').text + "\r\n#{url}"
    key = "#{price} - #{street} #{city} #{state} #{zip}"


    result = {
      street: street,
      city: city,
      state: state,
      zip: zip,
      price: price,
      img: img,
      url: url,
      description: description,
      key: key
    }
    return result
  end

end
