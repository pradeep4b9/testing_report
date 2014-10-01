class Profile
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Token

  token :field_name => :profile_id, :length => 12, :retry_count => 0, :pattern => "MV%d10"
  
  field :first_name, type: String
  field :middle_name, type: String
  field :last_name, type: String
  field :dob, type: String
  field :mobile_number, type: String
  field :profile_picture, type: String
  field :gender, type: String
  field :country, :type => String
  field :mobile_ctry_code, :type => String
  field :record_status, :type => String
  field :user_id, :type => String
  field :voice_status, :type => String

  belongs_to :user
  has_one :card_scan, :dependent => :destroy
end
