require 'rails_helper'

RSpec.describe Api::V1::EventsController do
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

      context 'and device_key param is missing' do
        it 'raises an error' do
          expect { post :create, event: {} }.to raise_error(
            ActionController::ParameterMissing,
            'param is missing or the value is empty: device_key'
          )
        end
      end
      context 'and event param is missing' do
        let!(:device) { create :device, user: user }
        it 'raises an error' do
          expect { post :create, device_key: device.key }.to raise_error(
            ActionController::ParameterMissing,
            'param is missing or the value is empty: event'
          )
        end
      end
      context 'and device_key does not exist or belongs to another user' do
        let!(:device) { create :device }
        let(:do_request) { post :create, device_key: device.key, event: {} }

        it 'raises an error' do
          expect { do_request }.to raise_error Mongoid::Errors::DocumentNotFound
        end
      end
      context 'and invalid params are sent' do
        let!(:device) { create :device, user: user }

        it 'returns JSON containing errors' do
          post :create, device_key: device.key, event: {type: 'test'}
          expect(JSON.parse(response.body)).to eq(
            'type' => ['is not included in the list']
          )
        end
      end
      context 'and valid params are sent' do
        let!(:device) { create :device, user: user }
        let(:do_request) do
          post :create, device_key: device.key, event: {type: 'item_received'}
        end

        it 'creates a new event' do
          expect { do_request }.to change(Event, :count).by(1)
        end
      end
    end
  end
end
