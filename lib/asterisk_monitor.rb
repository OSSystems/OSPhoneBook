require "socket"
require "open_port_checker"

class AsteriskMonitor
  def initialize
    info "New instance created."
  end

  def connect(host, port = nil)
    port = Rails.application.config.asterisk_monitor[:port] if port.nil?
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
    validation = {'Response' => 'Success',
                  'Message' => 'Authentication accepted'}
    @logged = check_response(get_response, validation)
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

    validation = {'Response' => 'Success'}
    check_response(get_response, validation)
  end

  private
  def send_action(action, params = {})
    request = (["Action: #{action}"] + params.collect{|k, v| "#{k}: #{v}"} + [""]).join("\r\n")
    debug "Request: " + request.inspect
    @socket.puts request+"\r\n"
  end

  def get_response
    raw_response = ""
    while not (line = @socket.readline).blank?
      raw_response << line
    end
    debug "Response: " + raw_response.inspect
    return raw_response unless raw_response.blank?
  end

  def check_response(raw_response, validation)
    response = hashify_response(raw_response)
    validation.all?{|key, value| response[key] == value}
  end

  def hashify_response(raw_response)
    response = {}
    raw_response.split("\r\n").each do |param|
      key, value = param.split(":", 2)
      response[key.strip] = value.nil? ? nil : value.strip
    end
    return response
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
