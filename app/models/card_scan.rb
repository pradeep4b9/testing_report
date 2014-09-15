class CardScan
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, type: String
  field :card_status, type: String

  field :first_name, type: String
  field :middle_name
  field :last_name
  field :date_of_birth, type: Time
  field :sex, type: String
  field :eyes_color, type: String
  field :hair_color, type: String
  field :height, type: String
  field :weight, type: String

  field :address, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :street, type: String
  field :country, type: String
  field :address_verification, type: Boolean

  field :idcard_type, type: String
  field :idcard_number, type: String
  field :issue_date, type: Time
  field :expiration_date, type: Time
  
  field :dl_class, type: String
  field :restriction, type: String
  field :endorsements, type: String

  field :face_image, type: String
  field :face_image_tmp, type: String
  field :signature_image, type: String
  field :signature_image_tmp, type: String

  mount_uploader :face_image, FaceImageUploader
  store_in_background :face_image

  # mount_uploader :signature_image, SignatureImageUploader
  # store_in_background :signature_image


  
end
