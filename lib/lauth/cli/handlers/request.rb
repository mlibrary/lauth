module Lauth
  module CLI
    module Handlers
      class Request < ::ROM::HTTP::Handlers::JSONRequest
        def self.call(dataset)
          if dataset.body_params.any?
            document = {}
            data = {}
            data[:type] = dataset.base_path
            data[:id] = dataset.body_params.delete(:id)
            data[:attributes] = dataset.body_params.dup
            document[:data] = data
            dataset.body_params.clear
            dataset.body_params.merge!(document)
          end
          super
        end
      end
    end
  end
end
