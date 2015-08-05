require 'rails_helper'

RSpec.describe Api::V1::SessionsController do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'when login param is missing' do
      it 'raises an error' do
        expect { post :create }.to raise_error(
          ActionController::ParameterMissing,
          'param is missing or the value is empty: login'
        )
      end
    end
    context 'when user does not exist' do
      let(:login) { {username: 'test@example.com', password: '123456'} }

      it 'returns HTTP Unauthorized' do
        post :create, login: login
        expect(response).to have_http_status :unauthorized
      end
      it 'returns correct message' do
        post :create, login: login
        expect(JSON.parse(response.body)).to eq(
          'error' => 'Invalid username or password.'
        )
      end
    end
    context 'when password is not valid' do
      let(:user) do
        create :user, password: 'a1234567', password_confirmation: 'a1234567'
      end
      let(:login) { {username: user.email, password: '1'} }

      it 'returns HTTP Unauthorized' do
        post :create, login: login
        expect(response).to have_http_status :unauthorized
      end
      it 'returns correct message' do
        post :create, login: login
        expect(JSON.parse(response.body)).to eq(
          'error' => 'Invalid username or password.'
        )
      end
    end
    context 'when credentials are valid' do
      let!(:user) do
        create :user, password: 'a1234567',
                      password_confirmation: 'a1234567',
                      confirmed_at: Time.zone.now
      end
      let(:login) { {username: user.email, password: 'a1234567'} }

      it 'returns HTTP OK' do
        post :create, login: login
        expect(response).to have_http_status :no_content
      end
      it 'signs in the user' do
        expect(controller).to receive(:sign_in).once.with(user)
        post :create, login: login
      end
    end
  end
  describe 'DELETE #destroy' do
    it 'signs out the user' do
      expect(controller).to receive(:sign_out).once
      delete :destroy
    end
    it 'returns HTTP OK' do
      delete :destroy
      expect(response).to have_http_status :no_content
    end
  end
end
