class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time
  
  field :first_name, type: String
  field :last_name, type: String
  field :terms_of_service, type: Boolean, default: false

  # SMS mobile
  field :mobile_number, :type => String 
  field :mobile_verification_code, :type => String, :default => ""
  field :mobile_verification_status, :type => Boolean, :default => false
  field :generated_at, :type => Time
  field :mobile_verification_count, :type => Integer, :default => 0

  field :two_factor_auth_status, type: Boolean, default: false
  field :two_factor_auth_sms_code, type: Integer, default: 0
  field :two_factor_auth_generated_at, :type => Time

  field :country, :type => String

  validates_presence_of :first_name, :last_name, :email
  validates_presence_of :encrypted_password
  # validates :mobile_number,  uniqueness: true, :uniqueness => {:message => "Mobile Phone Number is already registered."}
  validate :validate_user, :on => :create

  def validate_user
    errors.clear
    # if I18n.locale.to_s == "en"
    #   if first_name.present? && first_name !~ /^[a-z|A-Z| ]+$/
    #     errors["error_message"] << "Invalid First Name. Please enter only alphabets ex: abc or abc test"
    #   elsif last_name.present? && last_name !~ /^[a-z|A-Z| ]+$/
    #     errors["error_message"] << "Invalid Last Name. Please enter only alphabets ex: abc"
    #   end
    # end
    
    if first_name.blank? || ( first_name.present? && first_name !~ /^[a-z|A-Z| ]+$/ )
      errors["error_message"] << "Invalid First Name. Please enter only alphabets ex: abc or abc test"
    end

    if last_name.blank? || ( last_name.present? && last_name !~ /^[a-z|A-Z| ]+$/ )
      errors["error_message"] << "Invalid Last Name. Please enter only alphabets ex: abc"
    end

    if email.present? && User.where(email: email).present?
      errors["error_message"] << "Email is already registered."
    end

    if email.blank? || email !~ /^[a-z|A-Z|0-9|.|_]+@[a-z|A-Z|0-9|.|_]+$/i
      errors["error_message"] << "Invalid email"
    end

  end

  def full_name
    if first_name.present? && last_name.present?
      "#{first_name.split(" ")[0].humanize} #{last_name.humanize}"
    end
  end

end
