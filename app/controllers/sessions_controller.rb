class SessionsController < Devise::SessionsController
  def create
  	puts "coming session create"
		self.resource = warden.authenticate!(auth_options)
		set_flash_message(:notice, :signed_in) if is_flashing_format?
		if resource.voice_auth_status
			signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
			flash[:alert] = "verify your voice to signin to the user dashboard"
			redirect_to signin_voices_path(token:resource.claimant_id)
		else
			sign_in(resource_name, resource)
			yield resource if block_given?
			respond_with resource, location: after_sign_in_path_for(resource)
		end
	end
end
