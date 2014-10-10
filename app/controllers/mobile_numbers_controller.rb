class MobileNumbersController < ApplicationController
  before_filter :authenticate_user!

  def register
    if current_user.mobile_verification_status
      redirect_to card_scans_path
    end
  end

  def submit_register
    mobile_number = params[:profile][:mobile_number]
    country = params[:profile][:country]
    if country.present?
      mobile_number = "#{Country.find_country_by_name(country).country_code}" + "#{mobile_number}"
      verification_code = rand(999999).to_s.center(6, rand(9).to_s).to_i

      user = current_user
      user.country = country
      user.mobile_number = mobile_number
      user.mobile_verification_code = verification_code
      user.generated_at =  Time.now
      if user.save
        SendSms.perform_async(country, mobile_number, verification_code)

        profile = Profile.new({ "first_name" => user.first_name, "last_name" => user.last_name,
                            "mobile_number" => mobile_number, "gender" => params[:profile][:gender],
                            "country" => params[:profile][:country], "user_id" => user.id})
        profile.save

        redirect_to verify_mobile_numbers_path
      else
        error_message = user.errors["error_message"]
        if error_message.present?
          flash[:alert] = "#{error_message.join(", ")} !"
        else
          flash[:notice] = "Mobile Number already registered!"
        end
        redirect_to register_mobile_numbers_path
      end
    end
  end

  def verify
  end

  def submit_verify
    if current_user.mobile_verification_status
      redirect_to card_scans_path
    else
      user = current_user
      if params[:user][:mobile_verification_code].eql?(user.mobile_verification_code)
        user.mobile_verification_status = true
        user.two_factor_auth_status = true
        user.mobile_verification_count +=1
        user.discount_code = "mvims2013"
        user.discount_value = "9.90"
        user.save

        payment_params = { "payment_profile_id" => "MVIDISCOUNT100", "email" => user.email, 
                           "plan" => user.plan, "plan_amount" => "9.90",
                           "first_name" => user.first_name, "last_name" => user.last_name,
                           "discount_code" => user.discount_code, "discount_value" => user.discount_value,
                           "number_of_docs" => 0, "number_of_photos" => 3,
                           "payment_for" => "PLAN", "user_id" => user.id
                         }

        user_payment = UserPayment.new(payment_params)
        user_payment.save

        user.discount_code = nil
        user.discount_value = nil
        user.save

        redirect_to card_scans_path
      else
        redirect_to verify_mobile_numbers_path, :alert => "Please enter correct verification code"
      end
    end
  end

  def resend_code
    if Time.now.to_i > (current_user.generated_at.to_i + 600)
      if current_user.mobile_verification_count < 3
        verification_code = rand(999999).to_s.center(6, rand(9).to_s).to_i
        current_user.generated_at =  Time.now
        current_user.mobile_verification_code = verification_code
        current_user.save

        SendSms.perform_async(current_user.country, current_user.mobile_number, verification_code)
        response_details = {"status" => true, "code" => 3}
        redirect_to verify_mobile_numbers_path   
      else
        profile = current_user.profile
        profile.destroy
        redirect_to register_mobile_numbers_path
      end
    else
      flash[:alert] = "Please retry after 10 minutes!"
      redirect_to verify_mobile_numbers_path
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation,
                                   :mobile_number, :mobile_verification_code, :mobile_verification_status, :generated_at,
                                   :mobile_verification_count, :country, :plan, :discount_code, :discount_value)
    end

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :dob, :mobile_number, :gender, :country, :record_status, :user_id)
    end

    def user_payment_params
      params.require(:user_payment).permit(:payment_profile_id, :email, :plan, :plan_amount, :first_name, :last_name, :discount_code, 
                                           :number_of_docs, :number_of_photos, :payment_for, :user_id, :discount_value)
    end

end
