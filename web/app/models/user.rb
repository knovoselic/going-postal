class User
  include Mongoid::Document
  include UserDeviseFields

  has_many :devices
end
