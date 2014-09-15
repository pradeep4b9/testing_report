class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, type: String
  field :image, type: String
  field :image_tmp, type: String
  field :verified, type: String

  mount_uploader :image, ImageUploader
  store_in_background :image
  
end
