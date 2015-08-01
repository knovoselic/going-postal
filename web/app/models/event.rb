class Event
  include Mongoid::Document
  include Mongoid::Enum

  belongs_to :device

  field :timestamp, type: Time

  enum :type, %i(item_received item_taken), default: nil

  validates :timestamp, presence: true
end
