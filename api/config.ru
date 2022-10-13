require_relative "api"
require "yabeda/prometheus"

use Yabeda::Prometheus::Exporter

run Lauth::API::APP.new
