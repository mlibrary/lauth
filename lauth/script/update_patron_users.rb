#!/usr/bin/env ruby
# frozen_string_literal: true

arguments = ARGV
arguments = ARGV.drop(2) if ARGV.first == "run"

unless (1..2).cover?(arguments.length)
  warn "Usage: hanami run script/update_patron_users.rb PATRON_EXPORT [STAFF_MAP]"
  exit 64
end

require_relative "../config/app"
require "hanami/prepare"
require_relative "../lib/lauth/patron_importer"

begin
  Hanami.app.prepare(:persistence)
  importer = Lauth::PatronImporter.new(rom: Hanami.app["persistence.rom"])
  exit(importer.run(export_path: arguments[0], staff_map_path: arguments[1]) ? 0 : 1)
rescue => error
  warn "Patron import failed (#{error.class})."
  exit 1
end
