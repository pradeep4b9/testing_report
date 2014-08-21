class Photo
  include Mongoid::Document
  field :user_id, type: String
  field :image, type: String
  field :image_tmp, type: String
  field :verified, type: String
end
