require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @username = ENV["DASHBOARD_USERNAME"] = "test-admin"
    @password = ENV["DASHBOARD_PASSWORD"] = "test-password"
  end

  test "requires authentication" do
    get "/dashboard"
    assert_response :unauthorized
  end

  test "rejects invalid credentials" do
    get "/dashboard", headers: { "Authorization" => basic_auth_header("wrong", "wrong") }
    assert_response :unauthorized
  end

  test "renders the dashboard with valid credentials" do
    get "/dashboard", headers: { "Authorization" => basic_auth_header(@username, @password) }
    assert_response :success
    assert_select "h1", "Shortener Dashboard"
    assert_match links(:one).original_url, response.body
  end

  private

  def basic_auth_header(username, password)
    ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
