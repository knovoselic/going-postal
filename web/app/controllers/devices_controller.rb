class DevicesController < ApplicationController
  before_action :set_device, only: [:destroy]
  def index
    @devices = current_user.devices.entries
  end

  def destroy
    @device.destroy
    redirect_to action: :index
  end

  private

  def set_device
    @device = Device.find params[:id]
  end

  def device_params
    params.require(:device).allow(:location)
  end
end
