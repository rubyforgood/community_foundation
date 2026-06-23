class User < ApplicationRecord
  # validations: false so a password isn't required on create — passwordless
  # (magic-link) accounts have none. The presence-on-create check is dropped;
  # the length/confirmation validations below replace the rest.
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :scenarios, dependent: :destroy

  generates_token_for :email_confirmation, expires_in: 1.day do
    confirmed_at
  end

  generates_token_for :email_change, expires_in: 1.day do
    unconfirmed_email
  end

  # Magic-link sign-in token. Tied to the password salt so the link
  # auto-invalidates the moment a password is set or changed.
  generates_token_for :magic_link, expires_in: 30.minutes do
    password_salt&.last(10)
  end

  EMAIL_ADDRESS_FORMAT = URI::MailTo::EMAIL_REGEXP

  def self.valid_email_address?(value)
    value.to_s.match?(EMAIL_ADDRESS_FORMAT)
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: EMAIL_ADDRESS_FORMAT }
  validates :password, length: { minimum: 8, maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED }, allow_nil: true
  validates :password, confirmation: true, allow_blank: true
  validates :name, length: { maximum: 100 }, allow_blank: true

  def member_of?(organization)
    return false unless organization
    super_admin? || organizations.exists?(organization.id)
  end

  def membership_in(organization)
    organization && organization_memberships.find_by(organization_id: organization.id)
  end

  def admin_of?(organization)
    return false unless organization
    return true if super_admin?

    membership = membership_in(organization)
    membership&.admin? || membership&.owner?
  end

  def owner_of?(organization)
    return false unless organization
    return true if super_admin?

    membership_in(organization)&.owner?
  end

  def password_set?
    password_digest.present?
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end

  def display_name
    name.presence || email_address
  end
end
