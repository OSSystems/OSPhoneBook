unless ENV['CI_TESTS'].nil? or ENV['CI_TESTS'] == ''
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::RcovFormatter
  ]
  SimpleCov.start 'rails' do
    coverage_dir(File.expand_path(__dir__ + '/coverage'))
  end
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require File.expand_path(File.dirname(__FILE__) + '/asterisk_mockup_server')

class ActiveSupport::TestCase
  fixtures :all
  @@default_hash_value = 1

  ORIGINAL_ASTERISK_MONITOR_CONFIGS = Rails.application.config.asterisk_monitor.dup.freeze

  def default_hash(model, more_data = {})
    case model.to_s
    when Company.to_s
      data_hash = {:name => "Placebo S.A - #{@@default_hash_value}"}
    when Contact.to_s
      data_hash = {:name => "John Doe - #{@@default_hash_value}",
        :company_id => Company.create(default_hash(Company)).id}
    when PhoneNumber.to_s
      data_hash = {:number => "(053) 1234-#{@@default_hash_value + 5677}", :phone_type => 1,
        :contact_id => Contact.create(default_hash(Contact)).id}
    when Tag.to_s
      data_hash = {:name => "Abnormals - #{@@default_hash_value}"}
    when ContactTag.to_s
      data_hash = {:contact_id => Contact.create(default_hash(Contact)).id,
        :tag_id => Tag.create(default_hash(Tag)).id}
    when User.to_s
      data_hash = {:name => "Test Doe - #{@@default_hash_value}", :email => "testdoe-#{@@default_hash_value}@example.org",
        :extension => @@default_hash_value.to_s.rjust(4, "0")}
    when SkypeContact.to_s
      data_hash = {:username => "test_user_#{@@default_hash_value}",
        :contact_id => Contact.create(default_hash Contact).id}
    else
      raise "Unknown model #{model.to_s}!"
    end
    @@default_hash_value += 1

    return data_hash.merge(more_data)
  end

  def start_asterisk_mock_server(username='admin', password='secret', port=nil)
    stop_asterisk_mock_server if $asterisk_mock_server
    port = [port] if port
    $asterisk_mock_server = AsteriskMockupServer.new(username, password, port)
    Rails.application.config.asterisk_monitor[:port] = $asterisk_mock_server.port
    Rails.application.config.asterisk_monitor[:username] = username
    Rails.application.config.asterisk_monitor[:password] = password
    Rails.logger.info "Mock server port is " + $asterisk_mock_server.port.to_s
    $asterisk_mock_server.start
    $asterisk_mock_server
  end

  def stop_asterisk_mock_server
    $asterisk_mock_server ||= nil
    if $asterisk_mock_server
      $asterisk_mock_server.stop
      while $asterisk_mock_server.running?
        sleep 0.1
      end
      $asterisk_mock_server = nil
      return true
    end
    return false
  ensure
    Rails.application.config.asterisk_monitor = ORIGINAL_ASTERISK_MONITOR_CONFIGS.dup
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end
