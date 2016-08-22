require "asterisk_monitor_config"
require "socket"
require "open_port_checker"

class AsteriskMonitor
  def initialize
    info "New instance created."
  end

  def connect(host, port = nil)
    port = AsteriskMonitorConfig.host_data[:port] if port.nil?
    info "Connecting to #{host}:#{port}"
    @socket = TCPSocket.open(host, port)
  end

  def disconnect
    if @socket and !@socket.closed?
      @socket.close
      info "Disconnected"
      @socket = nil
      return true
    else
      return false
    end
  end

  def login(user, password)
    info "Logging in with username '#{user}'"
    send_action "Login", {"UserName" => user, "Secret" => password}
    @logged = (get_response == "Response: Success\n" +
      "Message: Authentication accepted\n")
  end

  def logged?
    @logged ||= false
  end

  def logoff
    info "Logging off"
    send_action "Logoff"
    true
  end

  def originate(channel, context, exten, priority, timeout)
    info "Dial to '#{exten}', from '#{channel}'"
    send_action "Originate", {
      "Channel"  => "SIP/" + channel,
      "Context"  => context,
      "Exten"    => exten,
      "Priority" => priority,
      "Timeout"  => timeout
    }

    get_response  == "Response: Success\n"
  end

  private
  def send_action(action, params = {})
    request = (["Action: #{action}"] + params.collect{|k, v| "#{k}: #{v}"} + [""]).join("\n")
    debug "Request: " + request.inspect
    @socket.puts request+"\n"
  end

  def get_response
    raw_response = ""
    while not (line = @socket.readline).blank?
      raw_response << line
    end
    debug "Response: " + raw_response.inspect
    return raw_response unless raw_response.blank?
  end

  %w(debug info warn error fatal).each do |method|
    src = <<-END_SRC
    def #{method}(message)
      message = "Asterisk Monitor [#{method.upcase}]: " + message
      Rails.logger.send :#{method}, message
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end
end
