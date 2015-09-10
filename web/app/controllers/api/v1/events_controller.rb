module Api
  module V1
    class EventsController < BaseController
      skip_before_action :authenticate_user!

      def create
        @device = Device.find_by key: device_key
        @event = Event.new event_params
        @event.device = @device

        if @event.save
          send_push_notification
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

      def send_push_notification
        Parse.init(
          application_id: '4aDYgLKaevqtk3bVCZSZB6zDGYIFJ3W8XfP81uxZ',
          api_key: 'DxEiCtQ17tfsyG1mwt3rbPuZVhCRUUNy5AUmDOgp'
        )
        push = Parse::Push.new alert: "You've just received something!"
        push.where = {userHash: Digest::MD5.hexdigest(@device.user.email)}
        push.save
      end
    end
  end
end
