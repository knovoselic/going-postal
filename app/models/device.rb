class Device
  include Mongoid::Document

  belongs_to :user
end
