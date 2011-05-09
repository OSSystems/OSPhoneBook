class ContactTag < ActiveRecord::Base
  set_table_name "contacts_tags"

  belongs_to :contact
  belongs_to :tag

  validates_presence_of :contact, :tag
end
