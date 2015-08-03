require 'rails_helper'

RSpec.describe Api::V1::DevicesController do
  describe 'POST #create' do
    before { request.accept = 'application/json' }

    context 'when user is not signed in' do
      it 'returns 404 Unauthorized' do
        sign_out
        post :create
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'when user is signed in' do
      let(:user) { build :user }
      before { sign_in user }

      context 'and device param is missing' do
        it 'raises an error' do
          expect { post :create }.to(
            raise_error ActionController::ParameterMissing
          )
        end
      end
      context 'and invalid params are sent' do
        it 'returns JSON containing errors' do
          post :create, device: {location: '', key: ''}
          expect(JSON.parse(response.body)).to eq(
            'key' => ["can't be blank"],
            'location' => ["can't be blank"]
          )
        end
      end
      context 'and valid params are sent' do
        let(:do_request) do
          post :create, device: {location: 'Test', key: '123456'}
        end

        it 'creates a new device' do
          expect { do_request }.to change(Device, :count).by(1)
        end
      end
    end
  end
end
