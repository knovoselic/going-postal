class DevicesController < ApplicationController
  before_action :set_device, only: [:update, :destroy]
  def index
    render_devices_and_events
  end

  def update
    @device.update device_params
    render_devices_and_events
  end

  def destroy
    @device.destroy
    render_devices_and_events
  end

  private

  def render_devices_and_events
    @devices = current_user.devices.entries
    render :index
  end

  def set_device
    @device = Device.find params[:id]
  end

  def device_params
    params.require(:device).permit(:location)
  end
end
