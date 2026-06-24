class Organization < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships
  has_many :scenarios, dependent: :destroy
  has_many :allocation_categories, dependent: :destroy

  has_one_attached :logo

  normalizes :subdomain, with: ->(s) { s.strip.downcase }

  validate :logo_is_a_reasonable_image

  validates :name, presence: true
  validates :subdomain,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/, message: "only letters, numbers, and hyphens" },
    length: { maximum: 63 },
    exclusion: { in: %w[ www mail ftp admin api app root ], message: "is reserved" }
  validates :website,
    presence: true,
    format: { with: URI::DEFAULT_PARSER.make_regexp(%w[ http https ]), message: "must be a valid URL" }

  private

  MAX_LOGO_BYTES = 5.megabytes

  def logo_is_a_reasonable_image
    return unless logo.attached?

    unless logo.content_type.to_s.start_with?("image/")
      errors.add(:logo, "must be an image")
    end

    if logo.byte_size > MAX_LOGO_BYTES
      errors.add(:logo, "must be smaller than 5 MB")
    end
  end
end
