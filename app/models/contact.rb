class Contact < ActiveRecord::Base
  belongs_to :company
  has_many :phone_numbers

  validates_presence_of :name, :company
  validates_uniqueness_of :name
end
