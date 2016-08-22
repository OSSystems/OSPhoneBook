require 'asterisk_monitor'
require 'asterisk_monitor_config'

module AsteriskDialUp
  class AuthenticationError < StandardError;
    MESSAGE = 'Asterisk username or password is invalid.'.freeze

    def message
      MESSAGE
    end
  end

  def dial_asterisk(origin_extension, dial_target)
    host_data = AsteriskMonitorConfig.host_data
    login_data = AsteriskMonitorConfig.login_data
    originate_data = AsteriskMonitorConfig.originate_data

    monitor = AsteriskMonitor.new
    monitor.connect host_data[:host], host_data[:port]
    if monitor.login login_data[:username], login_data[:secret]
      monitor.originate(origin_extension,
                        originate_data[:context],
                        dial_target,
                        originate_data[:priority],
                        originate_data[:timeout])
      monitor.logoff
    else
      raise AuthenticationError.new
    end
    monitor.disconnect
  end
end
