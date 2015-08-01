FactoryGirl.define do
  factory :event do
    timestamp { Time.zone.now }
    association :device
  end
end
