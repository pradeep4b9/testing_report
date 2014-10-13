class DashboardController < ApplicationController
  before_filter :authenticate_user!

  protect_from_forgery
  layout "card_scans"

  def index
  	if current_user.mobile_number.blank?
      redirect_to register_mobile_numbers_path
    elsif !current_user.mobile_verification_status
      redirect_to verify_mobile_numbers_path
    elsif current_user.profile.record_status != "match"
      redirect_to card_scans_path
    else
  		@profile = current_user.profile
  		@card_scan = @profile.card_scan if @profile.present?
  		@photo = current_user.photos.where(verified: true).last
  	end
  end

 end
