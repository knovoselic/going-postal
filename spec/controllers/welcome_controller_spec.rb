require 'rails_helper'

RSpec.describe WelcomeController do
  describe 'GET #index' do
    context 'when user is not signed in' do
      it 'renders index view' do
        get :index
        expect(response).to render_template :index
      end
    end
    context 'when user is signed in' do
      it 'redirects to Dashboard controller' do
        sign_in_user
        get :index
        expect(response).to redirect_to :dashboard
      end
    end
  end
end
