require 'rails_helper'

RSpec.describe Event do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  context 'validations' do
    it { should validate_presence_of :timestamp }
  end
end
