class PhoneNumber < ActiveRecord::Base
  belongs_to :contact

  validates_presence_of :phone_type
  validates_presence_of :contact
end
