class MobileNumbersController < ApplicationController
  # before_filter :authenticate_user!

  def register
  end

  def submit_register
    puts "coming to here"
    puts params.inspect
  end

  def verify
  end

  def submit_verify
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation,
                                   :mobile_number, :mobile_verification_code, :mobile_verification_status, :generated_at,
                                   :mobile_verification_count, :country)
    end

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :dob, :mobile_number, :gender, :country)
    end

end