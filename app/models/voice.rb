class Voice
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, type: String
  field :claimant_id, type: String
  field :dialogue_id, type: String
end
