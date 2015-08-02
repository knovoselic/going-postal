class DevicesController < ApplicationController
  def index
    @devices = current_user.devices.entries
  end
end
