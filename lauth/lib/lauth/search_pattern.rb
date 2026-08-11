# frozen_string_literal: true

module Lauth
  module SearchPattern
    module_function

    def wildcard(value)
      escaped = value.chars.map do |character|
        /[\\%_]/.match?(character) ? "\\#{character}" : character
      end.join

      "%#{escaped.tr("*", "%")}%"
    end
  end
end