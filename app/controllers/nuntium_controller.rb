class NuntiumController < ApplicationController
  before_filter :authenticate

  def receive_at
    User.transaction do
      render :json => Report.process(params)
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Nuntium::Config['incoming_username'] && password == Nuntium::Config['incoming_password']
    end
  end
end
