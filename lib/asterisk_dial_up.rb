require 'asterisk_monitor'

module AsteriskDialUp
  class AuthenticationError < StandardError;
    MESSAGE = 'Asterisk username or password is invalid.'.freeze

    def message
      MESSAGE
    end
  end

  def dial_asterisk(origin_extension, dial_target)
    config = Rails.application.config.asterisk_monitor
    monitor = AsteriskMonitor.new
    monitor.connect config[:host], config[:port]
    if monitor.login config[:username], config[:secret]
      monitor.originate(origin_extension,
                        config[:context],
                        dial_target,
                        config[:priority],
                        config[:timeout])
      monitor.logoff
    else
      raise AuthenticationError.new
    end
    monitor.disconnect
  end
end
