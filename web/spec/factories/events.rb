FactoryGirl.define do
  factory :event do
    timestamp { Time.zone.now }
    type :item_received
    association :device
  end
end
