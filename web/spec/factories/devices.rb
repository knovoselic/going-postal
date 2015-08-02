FactoryGirl.define do
  factory :device do
    sequence(:location) { |n| "Location #{n}" }
    key '12345'
    association :user
  end
end
