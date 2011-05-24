module ContactsHelper
  DIAL_OPTIONS = ((1..9).to_a+[0]+('a'..'z').to_a).collect{|k| k.to_s}

  class << self
    include Rails.application.routes.url_helpers
    def get_dialing_options(contact)
      options = {}
      contact.phone_numbers.each_with_index do |phone, index|
        option = {}
        option[:phone_number] = phone.number
        option[:phone_path] = dial_path phone.id
        option[:dial_message] = get_dialing_message(contact, phone.number)
        options[DIAL_OPTIONS[index]] = option
      end
      options
    end

    def get_dialing_message(contact, phone_number)
      message = "Dialing "
      message << "#{contact.company.name} - " if contact.company
      message + "#{contact.name} on #{phone_number}"
    end
  end
end
