require 'asterisk_dial_up'
require 'asterisk_monitor'

class SkypeContact < ActiveRecord::Base
  include AsteriskDialUp
  belongs_to :contact

  validates_presence_of :username
  validates_length_of :username, :minimum => 6, :maximum => 32, :allow_blank => true
  validates_format_of :username, :with => /\A[a-z]/i, :allow_blank => true, :message => :must_start_with_letter
  validates_format_of :username, :with => /\A[a-z0-9\.,-_]+\Z/i, :allow_blank => true, :message => :must_have_only_letters_numbers_and_punctuation
  validates_uniqueness_of :username, :scope => :contact_id

  def dial(extension)
    dial_asterisk(extension, username_dial)
  end

  private
  def username_dial
    "Skype/"+username
  end
end
