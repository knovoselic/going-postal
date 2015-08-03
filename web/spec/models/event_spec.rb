require 'rails_helper'

RSpec.describe Event do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it 'defaults type to nil' do
    expect(described_class.new.type).to be_nil
  end

  it 'defaults timestamp to current time' do
    Timecop.freeze do
      expect(described_class.new.timestamp).to eq Time.zone.now
    end
  end

  context 'validations' do
    it { should validate_presence_of :timestamp }
    it { should validate_inclusion_of(:type).in_array(described_class::TYPE) }
    it 'does not allow nil value in type' do
      subject.type = nil
      subject.valid?
      expect(subject.errors[:type]).to include 'is not included in the list'
    end
  end

  context 'default scope' do
    let!(:documents) do
      [
        described_class.create(timestamp: Time.zone.now, type: :item_taken),
        described_class.create(timestamp: Time.zone.now + 5, type: :item_taken)
      ]
    end
    it 'sorts documents descending by timestamp' do
      expect(described_class.all).to eq documents.reverse
    end
  end
end
