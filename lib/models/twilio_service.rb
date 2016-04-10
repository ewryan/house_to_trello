class TwilioService

  def initialize config
    @config = config

    # Setup Twilio Client
    twilio_account_sid = @config["twilio"]["api_key"]
    twilio_auth_token = @config["twilio"]["token"]
    @twilio_client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token
  end

  def send_sms(hash, card)
    # Send SMS Message
    @config['twilio']['dest_phone_numbers'].each do |dest_phone_number|
      @twilio_client.messages.create(
        from: @config['twilio']['source_phone_number'],
        to: dest_phone_number,
        body: "#{hash[:key]}\n\n#{card.url}"
      )
    end
  end

end
