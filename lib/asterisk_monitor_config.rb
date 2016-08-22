module AsteriskMonitorConfig
  CONFIG_FILE_NAME = "config/asterisk.yml"

  class << self
    def host_data
      {:host => (@config["host"] or '127.0.0.1'), :port => (@config["port"] or 5038)}
    end

    def login_data
      {:username => @config["username"], :secret => @config["secret"]}
    end

    def originate_data
      {:channel => @config["channel"],
        :context => @config["context"],
        :priority => (@config["priority"] or 1),
        :timeout => (@config["timeout"] or 10000)}
    end

    def set_new_config(config)
      @config = config
    end

    private
    def load_config_from_file
      if File.exists? CONFIG_FILE_NAME
        YAML::load File.read(CONFIG_FILE_NAME)
      else
        {}
      end
    end
  end

  @config ||= load_config_from_file
  if @config.blank? and Rails.env.development?
    # We open a mock Asterisk server during development for testing purposes:
    require Rails.root.join("test", "asterisk_mockup_server.rb")
    config = {"host" => "127.0.0.1",
              "username" => "admin",
              "secret" => "secret",
              "channel" => "channel",
              "context" => "context",
              "timeout" => 10000,
              "priority" => 1}
    server = AsteriskMockupServer.new(config["username"], config["secret"]).start
    Rails.logger.info "Mock server port is " + server.port.to_s
    config["port"] = server.port
    AsteriskMonitorConfig.set_new_config config
  end
end
