# frozen_string_literal: true

module Lauth
  module Ops
    module Admin
      module Networks
        class Search
          include Deps[network_repo: "repositories.network_repo"]

          def call(params)
            modes = %i[ip prefix cidr].filter_map do |mode|
              [mode, params[mode]] unless params[mode].nil?
            end
            range_values = [params[:rangeStart], params[:rangeEnd]]
            modes_count = modes.length + (range_values.any?(&:nil?) ? 0 : 1)
            raise Lauth::Repositories::NetworkRepo::InvalidSearch, "exactly one search mode is required" unless modes_count == 1
            raise Lauth::Repositories::NetworkRepo::InvalidSearch, "rangeStart and rangeEnd are required together" if range_values.one?(&:nil?)

            networks = if range_values.all?
              network_repo.search_by_range(start_value: range_values[0], end_value: range_values[1])
            else
              method = modes.fetch(0).first
              network_repo.public_send("search_by_#{method}", modes.fetch(0).last)
            end
            {networks: networks}
          end
        end
      end
    end
  end
end
