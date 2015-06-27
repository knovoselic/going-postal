module Api
  class TestController < ApiController
    skip_before_action :verify_authenticity_token

    def email
      client = SendGrid::Client.new(
        api_user: Rails.application.secrets.sendgrid_username,
        api_key: Rails.application.secrets.sendgrid_password
      )

      mail = SendGrid::Mail.new do |m|
        m.to = 'kristijan.novoselic@gmail.com'
        m.from = 'no-reply@going-postal.me'
        m.subject = 'You have mail!'
        m.text = 'Someone just dropped off something for you :)'
      end
      puts client.send(mail)

      head :ok
    end
  end
end
