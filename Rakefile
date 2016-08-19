# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

unless ENV['CI_TESTS'].nil? or ENV['CI_TESTS'] == ''
  require 'ci/reporter/rake/minitest'
end

require File.expand_path('../config/application', __FILE__)
require 'rake'

OsPhoneBook::Application.load_tasks

unless ENV['CI_TESTS'].nil? or ENV['CI_TESTS'] == ''
  task :test => 'ci:setup:minitest'
end
