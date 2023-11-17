Hanami.app.register_provider :persistence, namespace: true do
  prepare do
    require "rom"

    opts = {
      connect_timeout: 5
    }
    config = ROM::Configuration.new(:sql, target["settings"].database_url, opts)

    register "config", config
    register "db", config.gateways[:default].connection
  end

  start do
    config = target["persistence.config"]

    config.auto_registration(
      target.root.join("lib/lauth/persistence"),
      namespace: "Lauth::Persistence"
    )

    register "rom", ROM.container(config)
  end
end
