require 'bundler/capistrano'
require "rvm/capistrano"
require 'yaml'
require 'tempfile'

DEPENDENCIES_APT_PACKAGES = ["autoconf",
                             "automake",
                             "bison",
                             "build-essential",
                             "curl",
                             "gawk",
                             "git-core",
                             "libffi-dev",
                             "libgdbm-dev",
                             "libncurses5-dev",
                             "libpq-dev",
                             "libreadline6-dev",
                             "libsqlite3-dev",
                             "libssl-dev",
                             "libtool",
                             "libxml2-dev",
                             "libxslt1-dev",
                             "libyaml-dev",
                             "nginx",
                             "pkg-config",
                             "sqlite3",
                             "zlib1g-dev"]

application_config_file_path = File.join(File.dirname(__FILE__), 'basic_config.yml')
application_config = YAML::load( File.read application_config_file_path )

database_config_file_path = File.join(File.dirname(__FILE__), 'database.yml')
database_config = YAML::load( File.read database_config_file_path )

# Deployment credentials and environment:
set :application, application_config["name"]
set :application_user, application_config["user"]
set :deploy_to, File.join("/srv/", application)
set :rails_env, "production"
set(:user) { set_info }
set :templates_path, "lib/templates/deploy"
set :nginx_path_prefix, "/etc/nginx/"
unless exists?(:nginx_local_config)
  set(:nginx_local_config) { File.join(templates_path, "nginx.conf.erb") }
end
# Path to where your remote config will reside
set(:nginx_remote_config) do
  File.join(nginx_path_prefix, "sites-available/#{application}.conf")
end
set :unicorn_socket, application_config["unicorn_socket"]
set :initd_template, File.join(templates_path, "init.d.erb")
set :initd_path_prefix, "/etc/init.d/"
set :initd_remote_config, File.join(initd_path_prefix, application)
set(:database_config_file) { get_database_config_file }
set :database_config_dir, "config/database_config"
set(:database) { get_selected_database }
set :sqlite_database_dir, File.dirname(database_config[rails_env]["database"])

# Roles:
role(:app) { set_info }

# RVM methods:
set :rvm_type, :system
set :rvm_ruby_string, :local
set :rvm_autolibs_flag, "enable"
set :rvm_install_with_sudo, true
set(:rvm_add_to_group) { user }
set :rvm_path, "/usr/local/rvm" # force path since rvm-capistrano tries to install in the user home dir

# GIT:
set :scm, :git
set :scm_verbose, true
set :repository, "git://github.com/OSSystems/OSPhoneBook.git"
set :git_shallow_clone, 1

# SSH:
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:paranoid] = true # comment out if it gives you trouble. newest net/ssh needs this set.

# Add a few directories to be shared between releases:
shared_children.push File.dirname(application_config["secret_token_file"])
shared_children.push database_config_dir
shared_children.push "tmp/sockets"

# Hooks
before 'deploy:cold', "deploy:set_database_config"
before 'deploy:setup', "deploy:dependencies"
before 'deploy:setup', 'rvm:install_rvm'
after 'rvm:install_rvm', 'close_sessions'  # restart sessions to avoid permission bugs
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset:
before 'deploy:setup', 'rvm:create_gemset' # only create gemset
before 'deploy:update', "deploy:add_database_dir_to_shared_if_sqlite"
after "deploy:update", "deploy:fix_permissions"
after "deploy:update", "deploy:copy_basic_config_file"
after "deploy:update", "deploy:copy_version_describe"
after "deploy:update", "deploy:link_database_config"
after "deploy:update", "deploy:cleanup"
after "deploy:migrate", "db:set_permissions"
after "deploy:schema_load", "db:set_permissions"

# Custom tasks
namespace :deploy do
  desc "Stop processes that bluepill is monitoring and quit bluepill"
  task :stop, :roles => [:app] do
    rvmsudo "bluepill #{application} stop" # stop the processes
    rvmsudo "bluepill #{application} quit" # stop monitoring
  end

  desc "Load bluepill configuration and start it"
  task :start, :roles => [:app] do
    rvmsudo "bluepill load config/#{application}.pill"
  end

  desc "Stop bluepill and all processes and restart everything"
  task :restart, :roles => [:app] do
    deploy.stop
    deploy.start
  end

  desc "bluepills monitored processes statuses"
  task :status, :roles => [:app] do
    rvmsudo "bluepill #{application} status"
  end

  desc "Installs all the application dependencies"
  task :dependencies do
    sudo "apt-get -qyu --force-yes update; true", :shell => "bash"
    dependencies = DEPENDENCIES_APT_PACKAGES
    dependencies << "postgresql" if database == "postgresql"
    sudo "apt-get -qyu --force-yes install #{dependencies.join(" ")}", :shell => "bash"
  end

  desc "Creates the user that will be used by the application"
  task :add_user do
    status = get_return_status("id -u #{application_user} >/dev/null 2>&1")
    if status != 0 # return status != 0 => user does not exist
      sudo "useradd --system --shell /bin/false #{application_user}"
    else
      puts "User '#{application_user}' already exists. Ignoring..."
    end

    if database == "postgresql"
      [application_user, "root"].each do |database_user|
        command = "#{sudo} -u postgres bash -c \"psql postgres -tAc \\\"SELECT 1 FROM pg_roles WHERE rolname='#{database_user}'\\\" | grep -q 1\""
        status = get_return_status(command)
        if status != 0 # return status != 0 => PostgreSQL user does not exist
          if database_user != "root"
            options = ["--no-createdb",
                       "--no-inherit",
                       "--no-createrole",
                       "--no-superuser",
                       "--no-password"].join(" ")
          else
            options = "--superuser --no-password"
          end

          sudo "createuser #{options} #{database_user}", :as => "postgres"
        else
          puts "PostgreSQL user '#{database_user}' already exists. Ignoring..."
        end
      end
    end
  end

  desc "Corrects the deployment user permissions in the application path"
  task :fix_permissions do
    log_file_path = File.join(deploy_to, "/shared/log/#{rails_env}.log")
    sudo "touch " + log_file_path
    sudo "chown -R #{user}:#{application_user} " + deploy_to
    sudo "chmod -R g-w " + deploy_to
    sudo "chmod -R g+w " + File.join(deploy_to, "/shared/log")
    sudo "chmod -R g+w " + File.join(deploy_to, "/shared/pids")
    sudo "chmod -R g+w " + File.join(deploy_to, "/shared/sockets")
    if database == "sqlite"
      sudo "chmod -R g+w " + File.join(deploy_to, "/shared/database")
    end
  end

  desc "Run the migrate rake task"
  task :migrate do
    prepare_logs_for_migration do
      sudo_command_user = "-u postgres" if database == "postgresql"
      run "rvm#{sudo} #{sudo_command_user} bash -c 'cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate'"
    end
  end

  desc "Load the schema into the database"
  task :schema_load do
    prepare_logs_for_migration do
      sudo_command_user = "-u postgres" if database == "postgresql"
      run "rvm#{sudo} #{sudo_command_user} bash -c 'cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:schema:load'"
    end
  end

  desc "Deploys and starts a `cold' application."
  task :cold do
    deploy.setup
    deploy.add_user
    deploy.fix_permissions
    deploy.add_initd_script
    deploy.update
    deploy.generate_secret_token
    deploy.generate_database_config
    db.create
    deploy.schema_load
    db.seed
    nginx.setup
    nginx.restart
    deploy.start
  end

  desc "Creates an init.d script for the application."
  task :add_initd_script do
    buffer = parse_template(initd_template)
    temp_filepath = "/tmp/#{application}_initd_temp_file"
    put buffer, temp_filepath
    sudo "update-rc.d #{application} remove"
    sudo "mv #{temp_filepath} #{initd_remote_config}"
    sudo "chmod +x " + initd_remote_config
    sudo "update-rc.d #{application} defaults"
  end

  desc "Copies the basic config file to the server."
  task :copy_basic_config_file do
    config_buffer = application_config.to_yaml
    config_filepath = File.join(current_path, "config/basic_config.yml")
    put config_buffer, config_filepath
  end

  desc "[internal] Copies the result of 'git describe' to the server"
  task :copy_version_describe do
    git_describe = %x[git describe 2> /dev/null].strip
    git_describe_filepath = File.join(current_path, "config/git_describe")
    put git_describe, git_describe_filepath
  end

  desc "Generate a file containing the application secret token."
  task :generate_secret_token do
    filepath = application_config["secret_token_file"]
    shared_dir = File.join(File.basename(File.dirname(filepath)), File.basename(filepath))
    filepath = File.join(shared_path, shared_dir)
    rvmsudo "rake secret > " + filepath
  end

  desc "Generate a file containing the application database configuration."
  task :generate_database_config do
    database_file_template = database_config_file
    remote_dir = File.join(shared_path, File.basename(database_config_dir))
    database_config_remote_filepath = File.join(remote_dir, "database.yml")
    top.upload database_file_template, database_config_remote_filepath
    database_remote_filepath = File.join(remote_dir, "database")
    put database, database_remote_filepath
    deploy.link_database_config
  end

  desc "[internal] Generate a link to the database config file."
  task :link_database_config do
    if database == "sqlite"
      linked_file = File.join deploy_to, "current/config/database.yml"
      file = File.join current_path, database_config_dir, "database.yml"
      run "rm -f #{linked_file}"
      run "ln -s #{file} #{linked_file}"
    end
  end

  desc "[internal] Set the database config file just before starting a new " +
    "deployment"
  task :set_database_config do
    # just by calling this variable the new config filename will be set:
    database_config_file
    deploy.add_database_dir_to_shared_if_sqlite
  end

  desc "[internal] Set the database directory if it is an sqlite directory"
  task :add_database_dir_to_shared_if_sqlite do
    if database == "sqlite"
      shared_children.push sqlite_database_dir
    end
  end
end

namespace :db do
  desc "Creates the database"
  task :create do
    command_user = (database == "postgresql" ? "postgres" : nil)
    rvmsudo "rake db:create", command_user
  end

  desc "Seeds the database with initial data"
  task :seed do
    rvmsudo "rake db:seed", application_user
  end

  desc "Set table permissions for the application user"
  task :set_permissions do
    if database == "postgresql"
      # To avoid fighting the string escaping with capistrano I added this small
      # sql script to be generated in runtime from a template, copied to the
      # server and run. After it's completion the generated file is deleted from
      # both the server and the local machine.
      #
      # -- Lucas
      database = database_config[rails_env]["database"]
      filepath = create_set_permission_sql_file(application_user)
      remote_filepath = File.join("/tmp", File.basename(filepath))
      begin
        upload filepath, remote_filepath
        sudo "bash -c 'cd #{current_path} && psql --file=#{remote_filepath} #{database}'", :as => "postgres"
      ensure
        File.delete filepath if File.exist?(filepath)
        sudo "rm -rf " + remote_filepath
      end
    end
  end
end

# Nginx:
namespace :nginx do
  desc "Parses and uploads nginx configuration for this app."
  task :setup, :roles => :app, :except => { :no_release => true } do
    sites_available_dir = File.dirname nginx_remote_config
    sites_enabled_dir = File.expand_path(File.join(sites_available_dir, "../sites-enabled"))
    sudo "mkdir -p " + sites_available_dir
    buffer = parse_template(nginx_local_config)
    temp_filepath = "/tmp/nginx_config_temp_file"
    sites_enabled_filepath = File.join(sites_enabled_dir, File.basename(nginx_remote_config))
    begin
      put buffer, temp_filepath
      sudo "mv #{temp_filepath} #{nginx_remote_config}"
      sudo "mkdir -p " + sites_enabled_dir
      sudo "rm -f " + sites_enabled_filepath
      sudo "ln -s #{nginx_remote_config} #{sites_enabled_filepath}"
    ensure
      sudo "rm -f " + temp_filepath
    end
  end

  desc "Parses config file and outputs it to STDOUT (internal task)"
  task :parse, :roles => :app, :except => { :no_release => true } do
    puts parse_template(nginx_local_config)
  end

  desc "Restart nginx"
  task :restart, :roles => :app, :except => { :no_release => true } do
    sudo "service nginx restart"
  end

  desc "Stop nginx"
  task :stop, :roles => :app, :except => { :no_release => true } do
    sudo "service nginx stop"
  end

  desc "Start nginx"
  task :start, :roles => :app, :except => { :no_release => true } do
    sudo "service nginx start"
  end

  desc "Show nginx status"
  task :status, :roles => :app, :except => { :no_release => true } do
    sudo "service nginx status"
  end
end

desc "[internal] Closes all active sessions."
task :close_sessions do
  sessions.values.each { |session| session.close }
  sessions.clear
end

def create_set_permission_sql_file(application_user)
  set_permissions_template_filepath =  "db/set_permissions_template.sql"
  set_permissions = File.read(set_permissions_template_filepath)
  set_permissions = set_permissions % {:application_user => application_user}
  set_permissions_file = Tempfile.new('set_permissions')
  set_permissions_file.write set_permissions
  set_permissions_file.close
  return set_permissions_file.path
end

def get_return_status(command)
  status = nil
  run "#{command}; echo return code: $?" do |channel, stream, data|
    if data =~ /return code: (\d+)/
      status = $1.to_i
    else
      Capistrano::Configuration.default_io_proc.call(channel, stream, data)
    end
  end
  return status
end

def parse_template(file)
  require 'erb'
  template = File.read(file)
  return ERB.new(template).result(binding)
end

def rvmsudo(command, rvmsudo_user=nil)
  rvmsudo_user = rvmsudo_user.nil? ? "" : "-u #{rvmsudo_user} "
  run "rvm#{sudo} #{rvmsudo_user} bash -c 'cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec #{command}'"
end

def prepare_logs_for_migration
  log_file_path = File.join(current_path, "log/#{rails_env}.log")
  schema_file_path = File.join(current_path, "db/schema.rb")
  sudo "touch " + log_file_path
  sudo "touch " + schema_file_path
  sudo "chmod o+w " + log_file_path
  sudo "chmod o+w " + schema_file_path
  yield
  sudo "chmod o-w " + schema_file_path
  sudo "chmod o-w " + log_file_path
end

def ask_info(message, invalid_data_message, valid_options=[])
  if valid_options.size == 1
    puts "Autoselected database configurations only option: #{valid_options.first}"
    return valid_options.first
  end

  input = nil
  valid_options_messages = []
  valid_options.each_with_index do |option, i|
    valid_options_messages << "  #{(i+1).to_s}. #{option}"
  end
  valid_options_messages = valid_options_messages.join("\n")

  while input.nil? or input.empty?
    if not valid_options.empty? and valid_options.include?(input)
      break
    end

    if not valid_options.empty?
      puts message
      puts valid_options_messages
      print "Select one: "
    else
      print message
    end

    input = $stdin.gets.strip
    if input.empty? or (not valid_options.empty? and input.to_i > valid_options.size or input.to_i < 1)
      puts invalid_data_message
      input = nil
    end
  end

  if not valid_options.empty?
    input = valid_options[input.to_i-1]
  end

  return input
end

def set_info
  message = "Server hostname/address: "
  invalid_message = "Invalid server hostname/address."
  server ENV["SERVER"] || ask_info(message, invalid_message), :web,  :app,  :db, :primary => true

  message = "Server username with sudo or root: "
  invalid_message = "Invalid server username.\n\n"
  set :user, ENV["SERVER_USERNAME"] || ask_info(message, invalid_message)

  return
end

def get_database_config_file
  valid_config_options = {"postgresql" => "database.yml.postgresql.sample",
    "sqlite" => "database.yml.sqlite3.example"}
  valid_options = valid_config_options.keys
  message = "Which database would you like to use? "
  invalid_message = "Invalid database option."
  selected_option = ask_info(message, invalid_message, valid_options)
  set :database, selected_option
  config_file = valid_config_options[selected_option]
  return File.join("config", config_file)
end

def get_selected_database
  database_remote_filepath = File.join(shared_path, File.basename(database_config_dir), "database")
  tempfile = Dir::Tmpname.make_tmpname "/tmp/cap_#{application}", nil
  buffer = nil
  begin
    top.get database_remote_filepath, tempfile
    buffer = File.read tempfile.strip
  rescue Exception
    # meh... file doesn't exists...
  ensure
    FileUtils.remove_entry_secure tempfile if File.exist? tempfile
  end
  if buffer.nil? or buffer.empty?
    puts "[WARNING] No database has been created yet. Ignoring..."
  else
    return buffer
  end
end
