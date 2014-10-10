class Voice
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :claimant_id, type: String
  field :dialogue_id, type: String
  field :login_attempts, :type => Integer, default: 0
  field :login_status, :type => Boolean, default: false

end
