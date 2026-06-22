# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/registration_mailer/confirmation
  def confirmation
    RegistrationMailer.confirmation(User.take, Organization.take)
  end

  # Preview this email at http://localhost:3000/rails/mailers/registration_mailer/email_change
  def email_change
    user = User.take
    user.unconfirmed_email = "new-address@example.com"
    RegistrationMailer.email_change(user, Organization.take)
  end
end
