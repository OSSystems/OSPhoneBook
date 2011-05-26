class Tag < ActiveRecord::Base
  has_many :contacts_tags, :class_name => "ContactTag"
  has_many :contacts, :through => :contacts_tags

  validates_presence_of :name
  validates_uniqueness_of :name

  def <=>(another)
    self.name <=> another.name
  end
end
