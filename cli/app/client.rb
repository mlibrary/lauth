module Lauth
  module CLI
    module APP
      desc "Describe client here"
      arg_name "Describe arguments to client here"
      command :client do |c|
        c.action do |global_options, options, args|
          puts "client command ran"
        end
      end
    end
  end
end
