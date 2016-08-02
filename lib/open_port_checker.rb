module OpenPortChecker
  class << self
    def port_open?(ip, port, seconds=1)
      # => checks if a port is open or not on a remote host
      begin
        Timeout::timeout(seconds) do
          TCPSocket.new(ip, port).close
        end
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError, Timeout::Error
        false
      end
    end
  end
end
