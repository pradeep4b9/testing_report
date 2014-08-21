class CardScan
  include Mongoid::Document
  field :user_id, type: String
  field :card_status, type: String
  field :name, type: String
  field :picture, type: String
  field :signature, type: String
  field :dob, type: String
end
