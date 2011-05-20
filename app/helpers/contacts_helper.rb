module ContactsHelper
  def get_dialing_message(contact, phone_number)
    message = "Dialing "
    message << "#{@contact.company.name} - " if contact.company
    message + "#{@contact.name} on #{phone_number}"
  end
end
