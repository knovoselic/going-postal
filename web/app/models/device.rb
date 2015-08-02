class Device
  include Mongoid::Document

  index({key: 1}, unique: true)

  belongs_to :user
  has_many :events

  field :name, type: String
  field :key, type: String
  field :color, type: String, default: -> { SecureRandom.hex(3) }

  validates :user, presence: true
  validates :name, presence: true
  validates :color, presence: true
  validates :key, presence: true, uniqueness: true
end
