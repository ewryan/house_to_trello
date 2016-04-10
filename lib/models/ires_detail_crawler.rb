class IRESDetailCrawler

  def initialize config, mechanize_client, page
    @config = config
    @page = page
    @m = mechanize_client
  end

  def run   
    href = @page.attr('href')
    details_page = @m.get "http://www.iresis.com#{href}"

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
      href: href,
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
