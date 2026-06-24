require "test_helper"

class AllocationCategoryTest < ActiveSupport::TestCase
  setup { @organization = organizations(:arlington) }

  test "requires a name" do
    category = @organization.allocation_categories.build(type: "AllocationCategory::Program")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "persists its STI subclass via the type column" do
    category = AllocationCategory::Population.create!(organization: @organization, name: "Veterans")
    assert_equal "AllocationCategory::Population", category.reload.type
    assert_instance_of AllocationCategory::Population, AllocationCategory.find(category.id)
  end

  test "nests children under a parent" do
    parent = allocation_categories(:program_education)
    child = allocation_categories(:program_higher_education)
    assert_equal parent, child.parent
    assert_includes parent.children, child
  end

  test "roots scope returns only top-level categories" do
    roots = @organization.allocation_categories.roots
    assert_includes roots, allocation_categories(:program_education)
    assert_not_includes roots, allocation_categories(:program_higher_education)
  end

  test "belongs to the top-level Organization" do
    assert_instance_of Organization, allocation_categories(:program_education).organization
  end

  test "tab_label is human readable per subclass" do
    assert_equal "Program", AllocationCategory::Program.tab_label
    assert_equal "Organization", AllocationCategory::Organization.tab_label
  end
end
