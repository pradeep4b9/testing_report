class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, type: String
  field :image, type: String
  field :image_tmp, type: String
  field :verified, type: String
end
