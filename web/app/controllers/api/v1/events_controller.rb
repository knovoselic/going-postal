module Api
  module V1
    class EventsController < BaseController
      def create
        @device = current_user.devices.find_by key: device_key
        @event = Event.new event_params
        @event.device = @device

        if @event.save
          head :created
        else
          render json: @event.errors, status: :unprocessable_entity
        end
      end

      private

      def event_params
        params.require(:event).permit(:type)
      end

      def device_key
        params.require(:device_key)
      end
    end
  end
end
