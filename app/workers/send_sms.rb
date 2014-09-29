class SendSms
	include Sidekiq::Worker

  def perform(country, mobile, verification_code)
    if country.eql?("United States") 
      begin
        @clickatell_api = Clickatell::API.authenticate(ENV['CT_USA_API_ID'], ENV['CT_USA_USERNAME'], ENV['CT_USA_PASSWORD'])
      rescue
        response_details = {"status" => false, "code" => "901"}
        return response_details
      end
      begin
        response = @clickatell_api.send_message(mobile, "Your MYVERIFIEDID verification code is #{verification_code}. ", {:from => "15626615881", :set_mobile_originated => true})
        response_details = {"status" => true, "code" => @clickatell_api.message_status(response)}
        return response_details
      rescue Clickatell::API::Error => e
        response_details = {"status" => false, "code" => e.code}
        return response_details
      end
    
    else
      begin
        @clickatell_api = Clickatell::API.authenticate(ENV['CT_API_ID'], ENV['CT_USERNAME'], ENV['CT_PASSWORD'])
      rescue
        response_details = {"status" => false, "code" => "901"}
        return response_details
      end

      begin
        response = @clickatell_api.send_message(mobile, "Your MYVERIFIEDID verification code is #{verification_code}. ")
        response_details = {"status" => true, "code" => @clickatell_api.message_status(response)}
        return response_details
      rescue Clickatell::API::Error => e
        response_details = {"status" => false, "code" => e.code}
        return response_details
      end  
    end
  end
end