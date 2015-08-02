class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.in(device_id: current_user.device_ids).limit(10).entries
  end
end
