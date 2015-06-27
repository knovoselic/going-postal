require 'rails_helper'

RSpec.describe Device do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  context 'validations' do
    it { should validate_presence_of :user }
    it { should validate_presence_of :name }
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
end
