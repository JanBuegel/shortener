require "test_helper"

class LinkTest < ActiveSupport::TestCase
  test "generates a short_token before validation on create" do
    link = Link.new(original_url: "https://example.com")
    assert link.valid?
    assert link.short_token.present?
  end

  test "does not overwrite an already-present short_token" do
    link = Link.new(original_url: "https://example.com", short_token: "custom1")
    link.valid?
    assert_equal "custom1", link.short_token
  end

  test "requires original_url" do
    link = Link.new(original_url: nil)
    assert_not link.valid?
    assert_includes link.errors[:original_url], "can't be blank"
  end

  test "rejects non-http(s) schemes" do
    %w[javascript:alert(1) data:text/html,hi ftp://example.com not-a-url].each do |bad_url|
      link = Link.new(original_url: bad_url)
      assert_not link.valid?, "expected #{bad_url.inspect} to be invalid"
      assert_includes link.errors[:original_url], "must be a valid http or https URL"
    end
  end

  test "accepts http and https URLs" do
    %w[http://example.com https://example.com/path?query=1].each do |good_url|
      link = Link.new(original_url: good_url)
      assert link.valid?, "expected #{good_url.inspect} to be valid: #{link.errors.full_messages}"
    end
  end

  test "enforces short_token uniqueness at the model level" do
    existing = links(:one)
    link = Link.new(original_url: "https://example.com", short_token: existing.short_token)
    assert_not link.valid?
    assert_includes link.errors[:short_token], "has already been taken"
  end

  test "enforces short_token uniqueness at the database level" do
    existing = links(:one)
    link = Link.new(original_url: "https://example.com")
    link.define_singleton_method(:generate_short_token) { self.short_token ||= existing.short_token }
    link.short_token = existing.short_token

    assert_raises(ActiveRecord::RecordNotUnique) do
      link.save(validate: false)
    end
  end
end
