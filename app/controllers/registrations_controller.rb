class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    params[:user][:password] = params[:user][:password_confirmation] = generated_password
    user = User.new(user_params)
    sign_in(:user, user) if user.save
    redirect_to root_path
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
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

end 