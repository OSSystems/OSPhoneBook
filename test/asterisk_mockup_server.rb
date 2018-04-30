require "socket"

class AsteriskMockupServer
  def initialize(expected_username, expected_password, server_args = [])
    (server_args = [0]) if server_args.blank?
    @server = TCPServer.new(*server_args)
    @expected_username = expected_username
    @expected_password = expected_password
    @threads = []
    @threadsMutex = Mutex.new
    @served_connections = 0
    @running = false
  end

  def port
    @server.addr[1]
  end

  def serve(socket)
    Thread.new do
      Thread.current.abort_on_exception = true
      @threadsMutex.synchronize {
        @threads << Thread.current
        @served_connections += 1
      }
      Thread.current[:authenticated] = false
      begin
        raw_command = []
        while line = read_from_socket_with_timeout(socket)
          if line.blank?
            response = process_command(raw_command)
            break if response.nil?
            socket.write response
          else
            raw_command << line
          end
        end
      ensure
        socket.close unless socket.closed?
        @threadsMutex.synchronize {
          @threads.delete(Thread.current)
        }
      end
    end
  end

  def last_dialed_to
    @last_dialed_to
  end

  def last_dialed_from
    @last_dialed_from
  end

  def start
    @server_thread = Thread.new do
      Thread.current.abort_on_exception = true
      @running = true
      while @running
        break if @server.closed?
        socket = @server.accept
        serve(socket)
      end
    end
    self
  end

  def stop
    @threadsMutex.synchronize {
      @threads.each{|thread| thread.kill}
      @threads = []
    }
    @server_thread.kill if @server_thread
    @server.close unless @server.closed?
    @server_thread.join
    @running = false
    true
  end

  def running?
    @running
  end

  def connections
    @served_connections
  end

  private
  def process_command(raw_command)
    command = hashify_command(raw_command)

    case command[:action]
    when "Login"
      response = process_login_command(command)
    when "Originate"
      response = process_originate_command(command)
    when "Logoff"
      response = process_logoff_command(command)
    end
    response
  end

  def process_login_command(command)
    if command[:username] == @expected_username and
        command[:secret] == @expected_password
      response = create_response "Success", "Authentication accepted"
      Thread.current[:authenticated] = true
    else
      response = create_response "Error", "Authentication failed"
    end
    response
  end

  def process_originate_command(command)
    return nil unless Thread.current[:authenticated]
    keys = command.keys
    if [:channel, :context, :exten, :priority, :timeout].all?{|k| keys.include? k}
      @last_dialed_from = command[:channel]
      @last_dialed_to = command[:exten]
      response = create_response "Success"
    else
      response = create_response "Error"
    end
    response
  end

  def process_logoff_command(command)
    create_response "Goodbye", "Thanks for all the fish."
  end

  def create_response(response, message = "")
    response = "Response: #{response}"
    response << "\r\nMessage: #{message}" unless message.blank?
    response + "\r\n\r\n"
  end

  def hashify_command(raw_command)
    command = {}
    raw_command.each do |param|
      key, value = param.split(":")
      command[key.strip.downcase.to_sym] = value.strip
    end
    return command
  end

  def read_from_socket_with_timeout(socket, timeout_value=5)
    line = nil
    Timeout.timeout(timeout_value) { line = socket.gets}
    return line
  end
end
