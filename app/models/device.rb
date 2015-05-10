class Device
  include Mongoid::Document

  index({key: 1}, unique: true)

  belongs_to :user

  field :name, type: String
  field :key, type: String

  validates :user, presence: true
  validates :name, presence: true
  validates :key, presence: true, uniqueness: true
end
