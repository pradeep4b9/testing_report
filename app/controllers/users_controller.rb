class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:email_confirmation]
  
  def email_confirmation
    @user = User.find(params[:id])
    render :layout => 'application' 
  end

end