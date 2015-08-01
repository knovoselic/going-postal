class Event
  include Mongoid::Document

  belongs_to :device

  field :timestamp, type: Time

  validates :timestamp, presence: true
end
