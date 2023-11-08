# frozen_string_literal: true

development = ENV.fetch("HANAMI_ENV", "development") == "development"

require "concurrent"
require "localhost" if development

Bundler.require :tools if development
Bundler.root.join("tmp").then { |path| path.mkdir unless path.exist? }

max_threads_count = ENV.fetch "HANAMI_MAX_THREADS", 1 # 5
min_threads_count = ENV.fetch "HANAMI_MIN_THREADS", max_threads_count
threads min_threads_count, max_threads_count

port ENV.fetch "HANAMI_PORT", 2300
environment ENV.fetch "HANAMI_ENV", "development"
workers ENV.fetch "HANAMI_WEB_CONCURRENCY", 0 # Concurrent.physical_processor_count
worker_timeout 3600 if development
ssl_bind "localhost", "9050" if development
pidfile ENV.fetch "PIDFILE", "tmp/server.pid"
on_worker_boot { Hanami.shutdown }
plugin :tmp_restart

preload_app!