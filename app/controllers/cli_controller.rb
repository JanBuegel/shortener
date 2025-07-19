# app/controllers/cli_controller.rb
require "artii"

class CliController < ApplicationController
  def show
    a = Artii::Base.new
    response = a.asciify("Shortener")
    response << "\n"
    response << "Usage:\n"
    response << "  GET /links                             # List all shortened links\n"
    response << "  POST /links -d 'original_url=https://example.com'      # Create a new short link\n"
    render plain: response
  end
end
