# In production and CI, Rails eager loads every Allocation subclass for us.
# Everywhere else (development and local `bin/rails test`) eager loading is off,
# so this grandchild subclass isn't registered as a descendant when
# Scenario#ongoing_allocations builds its `type IN (...)` query and its rows get
# filtered out. Referencing it in a to_prepare block keeps it loaded.
# See https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance
unless Rails.env.production? || ENV["CI"].present?
  Rails.application.config.to_prepare do
    Allocation::GreatestCommunityNeed
  end
end
