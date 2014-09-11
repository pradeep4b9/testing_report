class CardScan
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :user_id, type: String
  field :cssn_data, type: String
  field :card_status, type: String
  field :name, type: String
  field :dob, type: Time
  field :id_number, type: String
	field :passport_number, type: String
	field :street, type: String
	field :city, type: String
	field :stateand_zip, type: String
	field :country, type: String
	field :address_verification, type: Boolean
	field :issue_date, type: Time
	field :expiration_date, type: Time
	field :sex, type: String
  field :face_image, type: String
  field :signature_image, type: String

  def parse_cssn_data
  	cssn_fields = %w(name dob id_number passport_number street city state_and_zip country expiration_date 
                     address_verification issue_date sex face_image signature_image)
	end
	
end
