class AllowNullPasswordDigest < ActiveRecord::Migration[8.1]
  def change
    # Passwordless (magic-link) accounts have no password, so password_digest
    # must be allowed to be NULL.
    change_column_null :users, :password_digest, true
  end
end
