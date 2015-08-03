module Api
  module V1
    class DevicesController < BaseController
      def create
        @device = Device.new device_params
        @device.user = current_user
        if @device.save
          head :created
        else
          render json: @device.errors, status: :unprocessable_entity
        end
      end

      private

      def device_params
        params.require(:device).permit(:location, :key)
      end
    end
  end
end
