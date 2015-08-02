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
      let(:user) { create :user }
      let(:device) { create :device, user: user }
      let(:another_user) { create :user }
      let(:another_device) { create :device, user: another_user, key: '1' }
      let!(:events) do
        10.times.map do |i|
          create :event, device: device, timestamp: Time.zone.now - i.seconds
        end
      end
      before do
        create :event, device: device, timestamp: Time.zone.now - 1.minute
        create :event, device: another_device, timestamp: Time.zone.now
        create :event, device: another_device, timestamp: Time.zone.now

        sign_in user
        get :index
      end

      it 'assigns last 10 events to instance variable' do
        expect(assigns(:events)).to eq events
      end
      it 'renders index view' do
        expect(response).to render_template :index
      end
    end
  end
end
