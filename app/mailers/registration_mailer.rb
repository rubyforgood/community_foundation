class RegistrationMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    mail subject: "Confirm your email address", to: user.email_address
  end
end
