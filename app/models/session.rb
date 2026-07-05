class Session < ApplicationRecord
  belongs_to :user

  def self.find_by_cookie(cookies)
    find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end
end
