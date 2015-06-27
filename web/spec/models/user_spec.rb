require 'rails_helper'

RSpec.describe User do
  subject { build described_class }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it { should be_kind_of UserDeviseFields }
end
