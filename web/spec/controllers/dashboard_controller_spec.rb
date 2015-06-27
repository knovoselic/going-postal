require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #index' do
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to :new_user_session
      end
    end
    context 'when user is signed in' do
      it 'renders index view' do
        sign_in_user
        get :index
        expect(response).to render_template :index
      end
    end
  end
end
