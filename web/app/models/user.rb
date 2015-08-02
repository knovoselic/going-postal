class User
  include Mongoid::Document
  include UserDeviseFields

  has_many :devices, dependent: :delete
end
