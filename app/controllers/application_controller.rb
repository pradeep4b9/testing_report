class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_filter :mobile_location


  def mobile_location
  	dev_ip = "199.193.252.231" # USA
  	# dev_ip = "207.179.146.70" # Canada
  	# dev_ip = "182.73.163.98" #Asia
  	# dev_ip = "5.11.143.22" #Europe
  	# dev_ip = "202.138.79.255" # Australia
  	# dev_ip = "201.221.132.22" # South America

  	ip = Rails.env == "production" ? request.remote_ip : dev_ip
  	data = Geocoder.search ip

  	continent = "Sorry, Not able to find your location."
  	country = data[0].data["country_name"] if data[0]
  	if country
	  	if country == "Reserved"
	  		continent = "Sorry, Not able to find your location."
	  	else
		  	continent = Country.find_country_by_name(country).continent
		  	continent = "Canada" if country == "Canada"
		  	continent = "USA" if country == "United States"
		  end
	  end
	  session[:continent] = continent
  end

  def after_sign_in_path_for(resource_or_scope)
    # if current_user.confirmed_at.blank?
    #   redirect_to :controller => "users", :action => 'email_confirmation', :id => current_user.id
    # elsif current_user.mobile_number.blank?
    #   redirect_to register_mobile_numbers_path
    # elsif current_user.mobile_verification_status
    #   redirect_to verify_mobile_numbers_path
    # elsif current_user.profile.record_status != "match"
    #   redirect_to card_scans_path
    # else
    #   redirect_to dashboard_index_path
    # end      
  end

end
