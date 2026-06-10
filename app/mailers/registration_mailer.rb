class RegistrationMailer < ApplicationMailer
  def confirmation(user, organization)
    @user = user
    @organization = organization
    mail subject: "Confirm your email address", to: user.email_address
  end
end
