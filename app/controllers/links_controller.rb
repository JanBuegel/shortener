require "terminal-table"

class LinksController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!, only: [ :create, :index ]

  def authenticate!
    api_key = request.headers["Authorization"].to_s.remove("Token ").strip
    unless api_key.present? && api_key == ENV["API_KEY"]
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
    redirect_to @link.original_url, allow_other_host: true, status: :permanent_redirect
  end
end
