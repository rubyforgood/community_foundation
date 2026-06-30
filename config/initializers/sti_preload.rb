# See https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance
Rails.application.config.to_prepare do
  Allocation::GreatestCommunityNeed
end
