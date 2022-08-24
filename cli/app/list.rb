module Lauth
  module CLI
    module APP
      desc "Describe list here"
      arg_name "Describe arguments to list here"
      command :list do |c|
        c.desc "Describe a switch to list"
        c.switch :s

        c.desc "Describe a flag to list"
        c.default_value "default"
        c.flag :f
        c.action do |global_options, options, args|
          # Your command logic

          # If you have any errors, just raise them
          # raise "that command made no sense"

          # puts ""
          # puts Lauth.client_repo.clients.count.to_s
          # puts args.to_s

          # uri = case ENV["RACK_ENV"]
          # when "development"
          #   URI("http://localhost:9292/clients")
          # when "test"
          #   URI("http://localhost:9191/clients")
          # when "compose"
          #   URI("http://api.lauth.local:9292/clients")
          # else
          #   URI("http://api.lauth.local:9292/clients")
          # end
          # res = Net::HTTP.get_response(uri)
          # data = JSON.parse(res.body)
          # data.each do |row|
          #   # puts "row"
          #   # puts row.to_s
          #   puts row["attributes"]["name"].to_s
          # end

          # puts "Before"

          Lauth::CLI.client_repo.clients.each do |client|
            puts client.name.to_s
          end

          # puts "After"
        end
      end
    end
  end
end
