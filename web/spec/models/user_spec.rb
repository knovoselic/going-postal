require 'rails_helper'

RSpec.describe User do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it { should be_kind_of UserDeviseFields }

  describe '#destroy' do
    subject { create described_class }
    let(:another_user) { create described_class }
    let!(:devices) do
      [
        create(:device, user: subject, key: '1'),
        create(:device, user: another_user, key: '2')
      ]
    end
    before { subject.destroy }

    it 'removes the user from the DB' do
      expect(described_class.unscoped.all).to eq [another_user]
    end
    it 'removes associated objects from the DB' do
      expect(Device.unscoped.all).to eq [devices.last]
    end
  end
end
