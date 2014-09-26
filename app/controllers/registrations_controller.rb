class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    user = User.new(user_params)

    if user.save!
      puts "im in user save ---------------"
      redirect_to :controller => "users", :action => 'email_confirmation', :id => user.id
    else
      error_message = user.errors["error_message"]
      if error_message.present?
        flash[:alert] = "#{error_message.join(", ")} !"
      else
        flash[:alert] = "Email already registered!"
      end
      redirect_to new_user_registration_path
    end
  end

  def update
    current_user.update_without_password(user_params)
    if params[:user][:password].present?
      current_user.password = params[:user][:password]
      current_user.password_confirmation = params[:user][:password]
      current_user.save
    end
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :terms_of_service)
    end

end
