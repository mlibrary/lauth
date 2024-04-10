# frozen_string_literal: true

require "hanami/boot"
require "yabeda/prometheus"

use Yabeda::Prometheus::Exporter

run Hanami.app
