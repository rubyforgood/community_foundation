class MagicLinkMailerPreview < ActionMailer::Preview
  def sign_in_link
    MagicLinkMailer.sign_in_link(User.take, Organization.take)
  end
end
