require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_key = ENV["API_KEY"] || "test-api-key"
    ENV["API_KEY"] = @api_key
  end

  test "create requires authentication" do
    post "/links", params: { original_url: "https://example.com" }
    assert_response :unauthorized
  end

  test "create rejects an invalid api key" do
    post "/links", params: { original_url: "https://example.com" },
      headers: { "Authorization" => "Token wrong-key" }
    assert_response :unauthorized
  end

  test "create succeeds with a valid api key and creates a link" do
    assert_difference("Link.count", 1) do
      post "/links", params: { original_url: "https://example.com" },
        headers: { "Authorization" => "Token #{@api_key}" }
    end
    assert_response :success
  end

  test "create rejects non-http(s) original_url" do
    assert_no_difference("Link.count") do
      post "/links", params: { original_url: "javascript:alert(1)" },
        headers: { "Authorization" => "Token #{@api_key}" }
    end
    assert_response :bad_request
  end

  test "index requires authentication" do
    get "/links"
    assert_response :unauthorized
  end

  test "index returns links as json" do
    get "/links", headers: { "Authorization" => "Token #{@api_key}" }, as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body["links"].is_a?(Array)
  end

  test "show redirects to the original_url and increments clicks" do
    link = links(:one)
    assert_difference("link.reload.clicks", 1) do
      get "/#{link.short_token}"
    end
    assert_response :permanent_redirect
    assert_equal link.original_url, response.location
  end

  test "show returns 404 for an unknown short_token" do
    get "/does-not-exist"
    assert_response :not_found
  end
end
