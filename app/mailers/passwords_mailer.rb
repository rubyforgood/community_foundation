class PasswordsMailer < ApplicationMailer
  def reset(user, organization)
    @user = user
    @organization = organization
    mail subject: "Reset your password", to: user.email_address
  end
end
