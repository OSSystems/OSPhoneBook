module ContactSearchHelper
  class << self
    include Rails.application.routes.url_helpers

    def search_for_contacts(search_string)
      unless search_string.blank?
        # split the keywords for the search:
        query_tokens = search_string.split(" ").collect{|token| "%"+token.gsub("%","").downcase+"%"}
        contacts_conditions = get_contacts_query_conditions(query_tokens)
        tags_conditions = get_tags_query_conditions(query_tokens)
        company_conditions = get_companies_query_conditions(query_tokens)
        phone_numbers_conditions = get_phone_numbers_query_conditions(query_tokens)
        skype_contacts_conditions = get_skype_contacts_query_conditions(query_tokens)
        conditions = merge_conditions(contacts_conditions, tags_conditions, company_conditions, phone_numbers_conditions, skype_contacts_conditions)

        contacts = execute_query(conditions)
      else
        contacts = []
      end

      hash = {}
      hash[:query] = search_string
      hash[:suggestions] = contacts.collect{|f| f.name}
      hash[:data] = contacts.collect{|contact| collect_contact_data(contact)}

      unless search_string.blank?
        name = search_string.strip
        new_contact_id = [9, contacts.size].min
        hash[:suggestions].insert(new_contact_id,"Create a new contact for '#{name}'...")
        hash[:data].insert(new_contact_id, [new_contact_path(:contact => {:name => name}), "", [], []])
      end

      hash
    end

    private
    def get_contacts_query_conditions(query_tokens)
      contacts_conditions = []
      query_tokens.size.times{contacts_conditions << "LOWER(#{Contact.table_name}.name) LIKE ?"}
      contacts_conditions = [contacts_conditions.join(" AND ")] + query_tokens
      contacts_conditions
    end

    def get_companies_query_conditions(query_tokens)
      companies_conditions = []
      query_tokens.size.times{companies_conditions << "LOWER(#{Company.table_name}.name) LIKE ?"}
      companies_conditions = [companies_conditions.join(" AND ")] + query_tokens
      companies_conditions
    end

    def get_tags_query_conditions(query_tokens)
      tags_conditions = []
      query_tokens.size.times{tags_conditions << "LOWER(#{Tag.table_name}.name) LIKE ?"}
      tags_conditions = [tags_conditions.join(" OR ")] + query_tokens
      tags_conditions
    end

    def get_phone_numbers_query_conditions(query_tokens)
      phone_conditions = []
      selected_tokens = []
      query_tokens.each do |token|
        token = token.scan(/[0-9]/).join
        next if token.blank?
        selected_tokens << "%#{token}%"
      end
      if selected_tokens.size > 0
        selected_tokens.size.times{phone_conditions << "#{PhoneNumber.table_name}.number LIKE ?"}
        phone_conditions = [phone_conditions.join(" OR ")] + selected_tokens
      end
      phone_conditions
    end

    def get_skype_contacts_query_conditions(query_tokens)
      tags_conditions = []
      query_tokens.size.times{tags_conditions << "LOWER(#{SkypeContact.table_name}.username) LIKE ?"}
      tags_conditions = [tags_conditions.join(" OR ")] + query_tokens
      tags_conditions
    end

    def merge_conditions(*unmerged_conditions)
      merged_conditions = [[]]

      unmerged_conditions.each do |conditions|
        conditions = clean_conditions(conditions)
        next if conditions.size == 0
        merged_conditions[0] << "(#{conditions[0]})"
        merged_conditions += conditions[1..-1] if conditions.size > 1
      end
      merged_conditions[0] = merged_conditions[0].join(" OR ")

      merged_conditions
    end

    def clean_conditions(conditions)
      conditions = [] if conditions.nil?
      conditions = [conditions] unless conditions.is_a?(Array)
      conditions.collect{|condition| condition.to_s}
    end

    def collect_contact_data(contact)
      data = []
      data << contact_path(contact)
      data << (contact.company ? contact.company.name : "")
      data << contact.phone_numbers.collect{|phone| phone.number} + contact.skype_contacts.collect{|contact| contact.username}
      data << contact.tags.collect{|tag| tag.name}
      data
    end

    def get_joins_query_string
      contact_table_name = Contact.table_name
      contact_tag_table_name = ContactTag.table_name
      tag_table_name = Tag.table_name
      company_table_name = Company.table_name
      phone_numbers_table_name = PhoneNumber.table_name
      skype_contacts_table_name = SkypeContact.table_name
      %(LEFT JOIN "#{company_table_name}" ) +
        %(ON "#{contact_table_name}"."company_id" = "#{company_table_name}"."id" ) +
        %(LEFT JOIN "#{phone_numbers_table_name}" ) +
        %(ON "#{contact_table_name}"."id" = "#{phone_numbers_table_name}"."contact_id" ) +
        %(LEFT JOIN "#{contact_tag_table_name}" ) +
        %(ON "#{contact_table_name}"."id" = "#{contact_tag_table_name}"."contact_id" ) +
        %(LEFT JOIN "#{tag_table_name}" ) +
        %(ON "#{tag_table_name}"."id" = "#{contact_tag_table_name}"."tag_id") +
        %(LEFT JOIN "#{skype_contacts_table_name}" ) +
        %(ON "#{contact_table_name}"."id" = "#{skype_contacts_table_name}"."contact_id")
    end

    def get_select_query_string
      %(DISTINCT "#{Contact.table_name}".*)
    end

    def execute_query(conditions)
      query = Contact.select(get_select_query_string)
      query = query.joins(get_joins_query_string)
      query = query.includes(:company, :tags, :phone_numbers, :skype_contacts)
      query = query.where(conditions)
      query = query.order("#{Contact.table_name}.name")
      query = query.limit 9
      contacts = query.readonly
    end
  end
end
