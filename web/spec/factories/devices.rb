FactoryGirl.define do
  factory :device do
    sequence(:name) { |n| "Device name #{n}" }
    key '12345'
    association :user
  end
end
