# Preview all emails at http://localhost:3000/rails/mailers/registration_mailer
class RegistrationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/registration_mailer/confirmation
  def confirmation
    RegistrationMailer.confirmation(User.take)
  end
end
