class PhoneNumber < ActiveRecord::Base
  belongs_to :contact

  validates_presence_of :phone_type

  def number=(raw_number)
    db_number = (raw_number.blank? ? raw_number : clean_number(raw_number))
    write_attribute :number, db_number
  end

  private
  def clean_number(number)
    number = number.dup.scan(/[0-9]/).join
    number.insert(0, "0") if number.size == 10
    number
  end
end
