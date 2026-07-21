require "terminal-table"

class LinksController < ApplicationController
  MAX_CREATE_ATTEMPTS = 3

  skip_forgery_protection
  before_action :authenticate!, only: [ :create, :index ]

  def authenticate!
    api_key = request.headers["Authorization"].to_s.sub(/\AToken /, "").strip
    expected_key = ENV["API_KEY"].to_s

    unless api_key.present? && expected_key.present? &&
           ActiveSupport::SecurityUtils.secure_compare(api_key, expected_key)
      render plain: "Unauthorized", status: :unauthorized
    end
  end

  def index
    @links = Link.all
    respond_to do |format|
      format.json do
        render json: { links: @links.map { |link| { original_url: link.original_url, short_url: "#{request.base_url}/#{link.short_token}", clicks: link.clicks } } }
      end
      format.text do
        table = Terminal::Table.new do |t|
          t.title = "Shortened Links"
          t.headings = ["Original URL", "Short URL", "Clicks"]
          t.rows = @links.map do |link|
            [link.original_url, "#{request.base_url}/#{link.short_token}", link.clicks]
          end
        end
        render plain: table.to_s
      end
    end
  end

  def create
    attempts = 0
    begin
      attempts += 1
      @link = Link.new(original_url: params[:original_url])
      if @link.save
        render plain: "#{request.base_url}/#{@link.short_token}\n"
      else
        render plain: "Fehler: #{@link.errors.full_messages.join(", ")}", status: 400
      end
    rescue ActiveRecord::RecordNotUnique
      # Extremely rare short_token collision race; retry with a freshly generated token.
      retry if attempts < MAX_CREATE_ATTEMPTS
      render plain: "Fehler: could not generate a unique short link, please try again", status: 500
    end
  end

  def show
    @link = Link.find_by!(short_token: params[:short_token])
    @link.increment!(:clicks)
    redirect_to @link.original_url, allow_other_host: true, status: :permanent_redirect
  end
end
