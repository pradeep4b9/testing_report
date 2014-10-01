class DashboardController < ApplicationController
  before_filter :authenticate_user!
 	
  protect_from_forgery
  layout "card_scans"

  def index
  	@profile = current_user.profile
  	@card_scan = @profile.card_scan if @profile.present?
  	@photo = current_user.photos.where(verified: true).last
  end
  
 end