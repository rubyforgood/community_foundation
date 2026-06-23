require "test_helper"

class Admin::ScenariosControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! "arlington.localhost"
    @owner = users(:one)
    @admin = users(:admin)
    @member = users(:passwordless)
  end

  test "owners and admins can view the dashboard" do
    sign_in_as(@owner)
    get admin_scenarios_path
    assert_response :success

    sign_in_as(@admin)
    get admin_scenarios_path
    assert_response :success
  end

  test "plain members are redirected away from the dashboard" do
    sign_in_as(@member)
    get admin_scenarios_path
    assert_redirected_to root_path
  end

  test "lists every scenario in the organization with its owner" do
    sign_in_as(@owner)
    get admin_scenarios_path

    assert_select "td", text: "Scenario 1"
    assert_select "td", text: "Admin plan"
    assert_select "td", text: @owner.display_name
    assert_select "td", text: @admin.display_name
  end

  test "does not show scenarios from another organization" do
    sign_in_as(@owner)
    get admin_scenarios_path

    assert_select "td", text: "Boston plan", count: 0
  end

  test "filters scenarios by user name on the server" do
    sign_in_as(@owner)
    get admin_scenarios_path(q: "admin")

    assert_select "td", text: "Admin plan"
    assert_select "td", text: "Scenario 1", count: 0
  end

  test "paginates results" do
    sign_in_as(@owner)
    # Create more scenarios than fit on one page so a second page exists.
    arlington = organizations(:arlington)
    (Admin::ScenariosController::PER_PAGE + 5).times do |i|
      arlington.scenarios.create!(user: @owner, name: "Bulk #{i}")
    end

    get admin_scenarios_path
    assert_select "tbody tr", count: Admin::ScenariosController::PER_PAGE

    get admin_scenarios_path(page: 2)
    assert_select "tbody tr", minimum: 1
  end
end
