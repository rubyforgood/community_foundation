class MagicLinkMailer < ApplicationMailer
  def sign_in_link(user, organization)
    @user = user
    @organization = organization
    mail subject: "Your sign-in link", to: user.email_address
  end
end
