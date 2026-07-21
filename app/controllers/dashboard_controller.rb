# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  before_action :authenticate!

  def index
    @links = Link.order(clicks: :desc, created_at: :desc)
    @total_links = @links.size
    @total_clicks = @links.sum(:clicks)
  end

  private

  def authenticate!
    authenticate_or_request_with_http_basic("Dashboard") do |username, password|
      expected_username = ENV["DASHBOARD_USERNAME"].to_s
      expected_password = ENV["DASHBOARD_PASSWORD"].to_s

      expected_username.present? && expected_password.present? &&
        ActiveSupport::SecurityUtils.secure_compare(username.to_s, expected_username) &&
        ActiveSupport::SecurityUtils.secure_compare(password.to_s, expected_password)
    end
  end
end
