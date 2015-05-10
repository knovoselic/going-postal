require 'rails_helper'

RSpec.describe Device do
  subject { build :device }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  context 'validations' do
    it { should validate_presence_of :user }
  end
end
