class ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation/new
  def new
    # build_resource({})
    respond_with self.resource
  end

  # POST /resource/confirmation
  # def create
  #   self.resource = resource_class.send_confirmation_instructions(resource_params)
  #   session[:plan] = resource.plan if resource.present?
  #   if successfully_sent?(resource)
  #     if session[:plan] && session[:plan] != "FREE"
  #       if session[:source_name]
  #         redirect_to "#{root_path}#{session[:source_name]}"
  #       else
  #         if resource.is_pcloud.eql?("yes")
  #           redirect_to private_cloud_registration_path
  #         else
  #           redirect_to premium_registration_path
  #         end
  #       end
  #     else
  #       respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
  #     end
  #   elsif session[:plan] && session[:plan] != "FREE" && resource.errors
  #     user = User.where(email: resource.email).first
  #     if user.present?
  #       if user.confirmation_token.blank? && user.confirmation_sent_at.present?
  #         error = "Email was already confirmed, please try Login."
  #       end
  #     else
  #       error = "Email Account not found."
  #     end

  #     if resource.is_pcloud.eql?("yes")
  #       respond_with_navigational(resource){ redirect_to private_cloud_registration_path(:resend_email_confirm =>"y", :error => error ) }
  #     else
  #       respond_with_navigational(resource){ redirect_to premium_registration_path(:resend_email_confirm =>"y", :error => error ) }
  #     end
  #   else
  #     respond_with(resource)
  #   end
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      @user = resource
      @generated_password = Devise.friendly_token.first(8)
      @user.password = @generated_password
      @user.password_confirmation = @generated_password
      @user.save

      @mail_details = {"token" => @user.id, "password" => @generated_password}
      # UserMailer.delay.user_login_details(@user, @generated_password)
      # UserMailer.user_login_details(@mail_details).deliver
      # NotificationWorker.perform_async("user_login_details", @mail_details)
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end

  end

  protected

    # The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(resource_name)
      new_session_path(resource_name) if is_navigational_format?
    end

    # The path used after confirmation.
    def after_confirmation_path_for(resource_name, resource)
      after_sign_in_path_for(resource)
    end



end

