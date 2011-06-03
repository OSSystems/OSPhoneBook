module AsteriskMonitorConfig
  CONFIG_FILE_NAME = "config/asterisk.yml"

  private
  def self.load_config_from_file
    if File.exists? CONFIG_FILE_NAME
      YAML::load File.read(CONFIG_FILE_NAME)
    else
      {}
    end
  end

  @config ||= load_config_from_file

  public
  def self.set_new_config(config)
    @config = config
  end

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
  end
end
