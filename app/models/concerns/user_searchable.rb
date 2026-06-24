module UserSearchable
  extend ActiveSupport::Concern

  included do
    scope :search_by_user, ->(query) {
      relation = includes(:user).references(:user).order("users.name", "users.email_address")
      query = query.to_s.strip
      next relation if query.blank?

      like = "%#{sanitize_sql_like(query.downcase)}%"
      relation.where("LOWER(users.name) LIKE :q OR LOWER(users.email_address) LIKE :q", q: like)
    }
  end
end
