module ApplicationHelper
  def owner?
    Current.user&.owner_of?(Current.organization)
  end
end
