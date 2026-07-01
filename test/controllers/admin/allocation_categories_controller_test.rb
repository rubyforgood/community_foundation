require "test_helper"

class Admin::AllocationCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:one)
    @admin = users(:admin)
    @member = users(:passwordless)
    @education = allocation_categories(:program_education)
  end

  test "owners and admins can view the index" do
    sign_in_as(@owner)
    get admin_allocation_categories_path
    assert_response :success

    sign_in_as(@admin)
    get admin_allocation_categories_path
    assert_response :success
  end

  test "plain members are redirected away" do
    sign_in_as(@member)
    get admin_allocation_categories_path
    assert_redirected_to root_path
  end

  test "index groups the org's categories by type and nests children" do
    sign_in_as(@owner)
    get admin_allocation_categories_path

    assert_select "td", text: /Education/
    assert_select "td", text: /Higher Education/
    assert_select "td", text: /Children and Youth/
  end

  test "index does not show another organization's categories" do
    sign_in_as(@owner)
    get admin_allocation_categories_path

    assert_select "td", text: /Boston Arts/, count: 0
  end

  test "index marks the requested type as the active tab" do
    sign_in_as(@owner)
    get admin_allocation_categories_path(type: "AllocationCategory::Population")
    assert_select "button[data-tabs-target='tab'][data-type='AllocationCategory::Population'][data-active='true']"
    assert_select "button[data-tabs-target='tab'][data-type='AllocationCategory::Program'][data-active='false']"
  end

  test "new defaults the type to the requested tab" do
    sign_in_as(@owner)
    get new_admin_allocation_category_path(type: "AllocationCategory::Population")
    assert_select "select[name='allocation_category[type]'] option[selected][value='AllocationCategory::Population']"
  end

  test "new falls back to the first type when the requested type is invalid" do
    sign_in_as(@owner)
    get new_admin_allocation_category_path(type: "Nonsense")
    assert_select "select[name='allocation_category[type]'] option[selected][value=?]",
      AllocationCategory::TAB_CLASSES.first
  end

  test "create makes a category of the chosen type for the current org" do
    sign_in_as(@owner)
    assert_difference -> { organizations(:arlington).allocation_categories.count }, 1 do
      post admin_allocation_categories_path, params: {
        allocation_category: { type: "AllocationCategory::Population", name: "Veterans" }
      }
    end
    category = organizations(:arlington).allocation_categories.order(:created_at).last
    assert_equal "AllocationCategory::Population", category.type
    assert_equal "Veterans", category.name
    assert_redirected_to admin_allocation_categories_path(type: "AllocationCategory::Population")
  end

  test "create with a blank name re-renders the form" do
    sign_in_as(@owner)
    assert_no_difference -> { AllocationCategory.count } do
      post admin_allocation_categories_path, params: {
        allocation_category: { type: "AllocationCategory::Program", name: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create rejects a type outside the allowed list" do
    sign_in_as(@owner)
    assert_no_difference -> { AllocationCategory.count } do
      post admin_allocation_categories_path, params: {
        allocation_category: { type: "AllocationCategory", name: "Sneaky" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "update changes the name" do
    sign_in_as(@owner)
    patch admin_allocation_category_path(@education), params: {
      allocation_category: { name: "Schooling" }
    }
    assert_equal "Schooling", @education.reload.name
    assert_redirected_to admin_allocation_categories_path(type: @education.type)
  end

  test "destroy removes the category and its children" do
    sign_in_as(@owner)
    assert_difference -> { AllocationCategory.count }, -2 do
      delete admin_allocation_category_path(@education)
    end
    assert_redirected_to admin_allocation_categories_path(type: @education.type)
  end

  test "cannot edit another organization's category" do
    sign_in_as(@owner)
    get edit_admin_allocation_category_path(allocation_categories(:boston_program))
    assert_response :not_found
  end

  test "cannot destroy another organization's category" do
    sign_in_as(@owner)
    assert_no_difference -> { AllocationCategory.count } do
      delete admin_allocation_category_path(allocation_categories(:boston_program))
    end
    assert_response :not_found
  end
end
