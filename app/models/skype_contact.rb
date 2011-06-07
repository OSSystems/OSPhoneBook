require 'asterisk_monitor'
require 'asterisk_monitor_config'

class SkypeContact < ActiveRecord::Base
  belongs_to :contact

  validates_presence_of :username
  validates_length_of :username, :minimum => 6, :maximum => 32, :allow_blank => true
  validates_format_of :username, :with => /\A[a-z]/i, :allow_blank => true, :message => :must_start_with_letter
  validates_format_of :username, :with => /\A[a-z0-9\.,-_]+\Z/i, :allow_blank => true, :message => :must_have_only_letters_numbers_and_punctuation
  validates_uniqueness_of :username, :scope => :contact_id

  def username_dial
    "Skype/"+username
  end

  def dial(extension)
    host_data = AsteriskMonitorConfig.host_data
    login_data = AsteriskMonitorConfig.login_data
    originate_data = AsteriskMonitorConfig.originate_data

    monitor = AsteriskMonitor.new
    monitor.connect host_data[:host], host_data[:port]
    monitor.login login_data[:username], login_data[:secret]
    monitor.originate(extension,
                      originate_data[:context],
                      self.username_dial,
                      originate_data[:priority],
                      originate_data[:timeout])
    monitor.logoff
    monitor.disconnect
  end
end
