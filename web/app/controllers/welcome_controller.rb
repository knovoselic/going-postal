class WelcomeController < ApplicationController
  def index
    redirect_to :dashboard if user_signed_in?
  end
end
