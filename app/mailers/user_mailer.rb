class UserMailer < ActionMailer::Base
  #default from: "#{ENV['EMAIL_NOTIFICATION']}"
  default from: "\"My Verified ID\" <#{ENV['EMAIL_NOTIFICATION']}>"

  def user_login_details(mail_details)
    @mail_details = mail_details
    @user = User.find(@mail_details["token"])
    @email = @user.email
    @user_name = @user.full_name
    @password = @mail_details["password"]
    mail(:to => @email, :subject => "#{@user_name} My Verified ID login details.")
  end

end
