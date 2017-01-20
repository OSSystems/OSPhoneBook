class Contact < ActiveRecord::Base
  belongs_to :company
  has_many :phone_numbers
  has_many :skype_contacts
  has_many :contacts_tags, :class_name => "ContactTag"
  has_many :tags, :through => :contacts_tags

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :company

  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true
  accepts_nested_attributes_for :skype_contacts, :allow_destroy => true
end
