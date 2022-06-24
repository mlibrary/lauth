module Lauth
  desc "Digital Library Publishing Service Client"
  command :client do |c|
    c.desc "List all clients"
    c.command :list do |list|
      list.action do |global_options, options, args|
        service = Service::Client.new($connection) # standard:disable Style/GlobalVars
        service.list.each do |item|
          puts item
        end
      end
    end

    c.desc "Find client"
    c.command :find do |find|
      find.action do |global_options, options, args|
        help_now!("id is required") if args.empty?
        id = args.shift.to_i
        puts id
      end
    end

    c.desc "IP Address"
    c.command :ip do |ip|
      ip.action do |global_options, options, args|
        help_now!("ip is required") if args.empty?
        addr = args.shift.to_i
        puts addr
      end
    end

    c.default_command :list
  end
end
