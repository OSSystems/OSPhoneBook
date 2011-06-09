require 'asterisk_monitor'
require 'asterisk_monitor_config'

class PhoneNumber < ActiveRecord::Base
  belongs_to :contact

  validates_presence_of :phone_type

  def number=(raw_number)
    db_number = (raw_number.blank? ? raw_number : self.class.clean_number(raw_number))
    write_attribute :number, db_number
  end

  def number
    this_number = raw_number
    return this_number if this_number.blank?
    if this_number.match(/^(0[1-9][0-9])([1-9][0-9]{3})([0-9]{4})$/)
      return "(#{$1}) #{$2}-#{$3}"
    else
      this_number.sub(/^00/, "+")
    end
  end

  def raw_number
    read_attribute(:number)
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
                      number_dial,
                      originate_data[:priority],
                      originate_data[:timeout])
    monitor.logoff
    monitor.disconnect
  end

  def self.clean_number(number)
    number = number.dup.scan(/[0-9]/).join
    number.insert(0, "0") if number.size == 10
    number
  end

  private
  def number_dial
    "SIP/"+self.raw_number
  end
end
