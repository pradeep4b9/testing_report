class MviDeviseMailer < Devise::Mailer

  #default from: "#{ENV['EMAIL_NOTIFICATION']}"
  default from: "\"My Verified ID\" <#{ENV['EMAIL_NOTIFICATION']}>"
  #  def confirmation_instructions(record, opts={})
  #   super

  #   headers = {
  #       :subject => "Dear #{resource.first_name.camelize} #{resource.last_name.camelize}, confirm your email."
  #   }
  # end

  # def reset_password_instructions(record, opts={})
  #   super

  #   headers = {
  #       :subject => "Dear #{resource.first_name.camelize} #{resource.last_name.camelize}, reset your password"
  #   }
  # end

  # def unlock_instructions(record, opts={})
  #   super

  #   headers = {
  #       :subject => "Dear #{resource.first_name.camelize} #{resource.last_name.camelize}, unlock your account"
  #   }
  # end

  private

   def headers_for(action, opts)
    if action == :confirmation_instructions
      headers = {
        :subject => "Dear #{resource.full_name}, please confirm your My Verified ID email address.",
        :to => resource.email,
        :from => mailer_sender(devise_mapping),
        :reply_to => mailer_reply_to(devise_mapping),
        :template_path => template_paths,
        :template_name => action

    }.merge(opts)
    elsif action == :reset_password_instructions
      headers = {
        :subject => "Dear #{resource.full_name}, reset your My Verified ID password",
        :to => resource.email,
        :from => mailer_sender(devise_mapping),
        :reply_to => mailer_reply_to(devise_mapping),
        :template_path => template_paths,
        :template_name => action
    }.merge(opts)
    else
      headers = {
        :subject => "Dear #{resource.full_name}, unlock your My Verified ID account",
        :to => resource.email,
        :from => mailer_sender(devise_mapping),
        :reply_to => mailer_reply_to(devise_mapping),
        :template_path => template_paths,
        :template_name => action
    }.merge(opts)
    end
   end

end