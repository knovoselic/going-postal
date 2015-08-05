module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :verify_authenticity_token
      skip_before_action :verify_signed_out_user, only: %i(destroy)
      before_action :ensure_user_exists, only: %(create)
      before_action :authenticate_user!, only: [:destroy]

      def create
        if @user.valid_password? login_params[:password]
          sign_in @user
          head :no_content
        else
          invalid_login_attempt
        end
      end

      def destroy
        sign_out
        head :no_content
      end

      private

      def ensure_user_exists
        @user = User
                .find_for_database_authentication email: login_params[:username]
        invalid_login_attempt unless @user
      end

      def login_params
        @login_params ||= params.require(:login).permit %i(username password)
      end

      def invalid_login_attempt
        render json: {error: 'Invalid username or password.'},
               status: :unauthorized
      end
    end
  end
end
