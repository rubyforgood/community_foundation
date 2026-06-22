class RegistrationMailer < ApplicationMailer
  def confirmation(user, organization)
    @user = user
    @organization = organization
    mail subject: "Confirm your email address", to: user.email_address
  end

  def email_change(user, organization)
    @user = user
    @organization = organization
    mail subject: "Confirm your new email address", to: user.unconfirmed_email
  end
end
