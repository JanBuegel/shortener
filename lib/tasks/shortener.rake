# lib/tasks/shortener.rake
require "artii"
require "terminal-table"

namespace :shortener do
  desc "List all shortened links"
  task list: :environment do
    links = Link.all
    table = Terminal::Table.new do |t|
      t.title = "Shortened Links"
      t.headings = ["Original URL", "Short URL", "Clicks"]
      t.rows = links.map do |link|
        [link.original_url, "http://localhost:3000/#{link.short_token}", link.clicks]
      end
    end
    puts table
  end

  desc "Create a new short link, e.g. rake shortener:create[https://example.com]"
  task :create, [:original_url] => :environment do |t, args|
    if args[:original_url].blank?
      puts "Please provide an original URL. Usage: rake shortener:create[https://example.com]"
      exit
    end

    link = Link.create(original_url: args[:original_url])

    if link.persisted?
      puts "Successfully created short link: http://localhost:3000/#{link.short_token}"
    else
      puts "Error creating short link: #{link.errors.full_messages.join(", ")}"
    end
  end

  task default: :environment do
    a = Artii::Base.new
    puts a.asciify("Shortener")
    puts ""
    puts "Usage:"
    puts "  rake shortener:list                             # List all shortened links"
    puts "  rake shortener:create[https://example.com]      # Create a new short link"
  end
end

task :shortener => "shortener:default"
