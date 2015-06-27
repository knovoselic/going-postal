module UserDeviseFields
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :registerable, :confirmable,
           :recoverable, :rememberable, :validatable

    ## Database authenticatable
    field :email, type: String, default: ''
    field :encrypted_password, type: String, default: ''

    ## Recoverable
    field :reset_password_token, type: String
    field :reset_password_sent_at, type: Time

    ## Rememberable
    field :remember_created_at, type: Time

    ## Confirmable
    field :confirmation_token, type: String
    field :confirmed_at, type: Time
    field :confirmation_sent_at, type: Time
    field :unconfirmed_email, type: String # Only if using reconfirmable
  end
end
