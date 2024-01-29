require "rspec/expectations"

module CollectionStringHelpers
  # We want to avoid asserting the order of the collections, so we use this regex
  # to check the colon placement, and check for the elements separately.
  COLLECTION_FORMAT = /^:(?:[^:]+:)*$/

  # Break the returned string into tokens, including the delimiter.
  # E.g. :foo:bar: becomes [":", "foo", ":", "bar", ":"]
  def tokenize_collection_string(s)
    # Note: #split with a capture group has the side effect of
    # introducing empty strings; we drop these.
    s.split(/(:)/).reject(&:empty?)
  end

  extend RSpec::Matchers::DSL
  matcher :match_collection_string_format do |_|
    match do |actual|
      COLLECTION_FORMAT.match? actual
    end
    failure_message do |actual|
      "#{actual} did not match the format (#{COLLECTION_FORMAT})"
    end
  end
end
