class Organization < ApplicationRecord
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships

  normalizes :subdomain, with: ->(s) { s.strip.downcase }

  validates :name, presence: true
  validates :subdomain,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/, message: "only letters, numbers, and hyphens" },
    length: { maximum: 63 },
    exclusion: { in: %w[ www mail ftp admin api app root ], message: "is reserved" }
  validates :website,
    format: { with: URI::DEFAULT_PARSER.make_regexp(%w[ http https ]), message: "must be a valid URL" },
    allow_blank: true
end
