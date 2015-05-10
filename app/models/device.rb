class Device
  include Mongoid::Document

  belongs_to :user

  validates :user, presence: true
end
