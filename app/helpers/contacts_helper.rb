module ContactsHelper
  DIAL_OPTIONS = ((1..9).to_a+[0]+('a'..'z').to_a).collect{|k| k.to_s}

  class << self
    include Rails.application.routes.url_helpers
    def get_dialing_options(contact)
      options = {}
      phone_numbers_size = contact.phone_numbers.size
      contact.phone_numbers.each_with_index do |phone, index|
        option = {}
        option[:phone_type] = :phone
        option[:phone_number] = phone.number
        option[:phone_path] = dial_phone_path phone.id
        option[:dial_message] = get_dialing_message(contact, phone.number)
        options[DIAL_OPTIONS[index]] = option
      end

      contact.skype_contacts.each_with_index do |skype, index|
        option = {}
        option[:phone_type] = :skype
        option[:phone_number] = skype.username
        option[:phone_path] = dial_skype_path skype.id
        option[:dial_message] = get_dialing_message(contact, skype.username)
        options[DIAL_OPTIONS[index+phone_numbers_size]] = option
      end
      options
    end

    def get_dialing_message(contact, phone_number)
      message = "Dialing "
      message << "#{contact.company.name} - " if contact.company
      message + "#{contact.name} on #{phone_number}"
    end
  end

  def link_remove_tag(name, options = {})
    options[:class] = options[:class].to_s
    options[:class] += ' remove-tag'
    link_to(name, "javascript:void(0)", options)
  end
end
