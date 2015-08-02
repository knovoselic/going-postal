require 'rails_helper'

RSpec.describe Device do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  context 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :location }
    it { should validate_presence_of :color }
    it { should validate_presence_of :key }
    it 'requires key field to be unique across all devices' do
      create described_class
      subject.valid?
      expect(subject.errors[:key]).to include 'is already taken'
    end
  end

  describe '#key' do
    it 'has unique index' do
      result = described_class.index_specifications.count do |index|
        index.fields == [:key] && index.options[:unique] == true
      end
      expect(result).to be 1
    end
  end

  describe '#color' do
    it 'assigns random color for each new object' do
      expect(described_class.new.color).not_to eq described_class.new.color
    end
  end

  describe '#destroy' do
    subject { create described_class }
    let(:another_device) { create described_class, key: '1' }
    let!(:events) do
      [
        create(:event, device: subject),
        create(:event, device: another_device)
      ]
    end
    before { subject.destroy }

    it 'removes the device from the DB' do
      expect(described_class.unscoped.all).to eq [another_device]
    end
    it 'removes associated events from the DB' do
      expect(Event.unscoped.all).to eq [events.last]
    end
  end
end
