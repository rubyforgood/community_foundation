module Admin::AllocationCategoriesHelper
  def parent_options(category)
    scope = Current.organization.allocation_categories.where(type: category.type).order(:name)
    return scope if category.new_record?

    excluded_ids = [ category.id ] + descendant_ids(category)
    scope.where.not(id: excluded_ids)
  end

  private

  def descendant_ids(category)
    category.children.flat_map { |child| [ child.id ] + descendant_ids(child) }
  end
end
