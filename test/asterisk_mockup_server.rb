require "gserver"

class AsteriskMockupServer < GServer
  def initialize(expected_username, expected_password, gserver_args = [])
    (gserver_args[0] = 5038) if gserver_args.blank?
    super(*gserver_args)
    @expected_username = expected_username
    @expected_password = expected_password
    @raw_command = []
  end

  def serve(socket)
    while (line = socket.readline)
      if not line.blank?
        @raw_command << line
      else
        response = process_command
        @raw_command = []
        socket.puts response
      end
    end
  end

  def last_dialed_number
    @last_dialed_number
  end

  def last_dialed_extension
    @last_dialed_extension
  end

  private
  def process_command
    hashify_command

    case @command[:action]
    when "Login"
      response = process_login_command
    when "Originate"
      response = process_originate_command
    when "Logoff"
      process_logoff_command
    end
    response
  end

  def process_login_command
    if @command[:username] == @expected_username and
        @command[:secret] == @expected_password
      response = create_response "Success", "Authentication accepted"
    else
      response = create_response "Error", "Authentication failed"
    end
    response
  end

  def process_originate_command
    keys = @command.keys
    if [:channel, :context, :exten, :priority, :timeout].all?{|k| keys.include? k}
      @last_dialed_number = @command[:exten]
      @last_dialed_extension = @command[:channel]
      response = create_response "Success"
    else
      response = create_response "Error"
    end
    response
  end

  def process_logoff_command
    create_response "Goodbye", "Thanks for all the fish."
  end

  def create_response(response, message = "")
    response = "Response: #{response}"
    response << "\nMessage: #{message}" unless message.blank?
    response + "\n\n"
  end

  def hashify_command
    @command = {}
    @raw_command.each do |param|
      key, value = param.split(":")
      @command[key.strip.downcase.to_sym] = value.strip
    end
  end
end
