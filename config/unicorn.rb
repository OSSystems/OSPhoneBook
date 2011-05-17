worker_processes 1
user "www-data", "www-data"

APP_PATH = "/var/www/"

working_directory APP_PATH
listen 8080, :tcp_nopush => true

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30
pid APP_PATH + "tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
stderr_path APP_PATH + "log/unicorn.stderr.log"
stdout_path APP_PATH + "log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
