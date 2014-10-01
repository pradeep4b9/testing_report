class Voice
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, type: String
  field :claimant_id, type: String
  field :dialogue_id, type: String
  field :login_status, type: Boolean, :default => false
  field :login_attempts, type: Integer, :default => 0

  belongs_to :user
  
end
