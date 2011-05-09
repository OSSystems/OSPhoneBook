class Contact < ActiveRecord::Base
  belongs_to :company

  validates_presence_of :name, :company
  validates_uniqueness_of :name
end
