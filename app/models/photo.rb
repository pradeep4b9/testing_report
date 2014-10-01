class Photo
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Rails.application.routes.url_helpers

  field :title, type: String
  field :description, type: String
  field :image, type: String
  field :user_id, type: String
  field :image_tmp, type: String
  field :captured, type: Boolean, :default => false
  field :verified, type: Boolean, :default => false
  field :profile_picture, type: Boolean, :default => false
  field :tag_name, type: String
  field :tag_id, type: String
  field :photo_id_url, type: String
  field :match_score, type: String

  mount_uploader :image, ImageUploader
  store_in_background :image

  belongs_to :user
  has_one :photo_face, :dependent => :destroy
  has_one :photoid_face, :dependent => :destroy

  # has_one :photo_face, :dependent => :destroy

  # validates :image, 
  #   :presence => true, 
  #   :file_size => { 
  #     :maximum => 5.megabytes.to_i 
  #   } 

end