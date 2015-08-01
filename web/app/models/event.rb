class Event
  include Mongoid::Document
  include Mongoid::Enum

  belongs_to :device

  default_scope -> { desc :timestamp }

  enum :type, %i(item_received item_taken), default: nil
  field :timestamp, type: Time

  validates :timestamp, presence: true
end
