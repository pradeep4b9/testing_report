class PhotoFace
	include Mongoid::Document
  include Mongoid::Timestamps

  field :photo_id, type: String
 	field :face_details, type: Hash # The image frame to be processed(user's uploaded image)
 	field :status, type: String
 	field :error_code, type: String
 	field :error_message, type: String
 	field :score

end