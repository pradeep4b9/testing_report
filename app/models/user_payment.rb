class UserPayment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :payment_profile_id, type: String
  field :email, type: String
  field :plan, type: String
  field :plan_amount, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :discount_code, type: String
  field :number_of_docs, type: Integer
  field :number_of_photos, type: Integer
  field :payment_for, type: String
  field :user_id, type: String
  field :discount_value, type: String

  belongs_to :user

end