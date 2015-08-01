require 'rails_helper'

RSpec.describe Event do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it 'defaults type to nil' do
    expect(described_class.new.type).to be_nil
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
end
