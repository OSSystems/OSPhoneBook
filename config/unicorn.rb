# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# http://unicorn.bogomips.org/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'yaml'
require 'fileutils'
config_file_path = File.join(File.dirname(__FILE__), 'basic_config.yml')
application_config = YAML::load( File.read config_file_path )

rails_root = File.expand_path(File.join(File.dirname(__FILE__), "/../"))

if ENV["RAILS_ENV"] == "production"
  listen "unix:"+File.join(rails_root, application_config["unicorn_socket"]), :backlog => 64
else
  listen "*:3000"
end

worker_processes 1 # this should be >= nr_cpus

user application_config["user"], application_config["user"]

working_directory rails_root

timeout 30

pid_file = ENV["PID_FILE"] ? ENV["PID_FILE"] : File.join(rails_root, "tmp/pids/unicorn.pid")
pid pid_file

stderr_path File.expand_path(File.join(rails_root, "log/unicorn.log"))
stdout_path File.expand_path(File.join(rails_root, "log/unicorn.log"))

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

tmp_cache = File.join(rails_root, "tmp/cache")
tmp_sessions = File.join(rails_root, "tmp/sessions")
[tmp_cache, tmp_sessions].each do |directory|
  FileUtils.mkdir_p(directory)
  FileUtils.chown_R(nil, application_config["user"], directory)
  FileUtils.chmod_R("g+w", directory)
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # The following is only recommended for memory/DB-constrained
  # installations.  It is not needed if your system can house
  # twice as many worker_processes as you have configured.
  #
  # # This allows a new master process to incrementally
  # # phase out the old master process with SIGTTOU to avoid a
  # # thundering herd (especially in the "preload_app false" case)
  # # when doing a transparent upgrade.  The last worker spawned
  # # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  sleep 1
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
