class LinksController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!, only: [ :create ]

  def authenticate!
    api_key = request.headers["Authorization"].to_s.remove("Token ").strip
    unless api_key.present? && api_key == ENV["API_KEY"]
      render plain: "Unauthorized", status: :unauthorized
    end
  end

  def create
    @link = Link.new(original_url: params[:original_url])
    if @link.save
      render plain: "#{request.base_url}/#{@link.short_token}\n"
    else
      render plain: "Fehler: #{@link.errors.full_messages.join(", ")}", status: 400
    end
  end

  def show
    @link = Link.find_by!(short_token: params[:short_token])
    @link.increment!(:clicks)
    redirect_to @link.original_url, allow_other_host: true
  end
end
