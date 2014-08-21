class Profile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, type: String
  field :middle_name, type: String
  field :last_name, type: String
  field :dob, type: String
  field :mobile_number, type: String
  field :profile_picture, type: String
  
end
