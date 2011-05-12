module ContactSearchHelper
  class << self
    include Rails.application.routes.url_helpers

    def search_for_contacts(search_string)
      unless search_string.blank?
        # split the keywords for the search:
        query_tokens = search_string.split(" ").collect{|token| "%"+token+"%"}
        contacts_conditions = get_contacts_query_conditions(query_tokens)
        tags_conditions = get_tags_query_conditions(query_tokens)
        conditions = merge_conditions(contacts_conditions, tags_conditions)

        contacts = execute_query(conditions)
      else
        contacts = []
      end

      hash = {}
      hash[:query] = search_string
      hash[:suggestions] = contacts.collect{|f| f.name}
      hash[:data] = contacts.collect{|contact| collect_contact_data(contact)}

      hash
    end

    private
    def get_contacts_query_conditions(query_tokens)
      contacts_conditions = []
      query_tokens.size.times{contacts_conditions << "LOWER(#{Contact.table_name}.name) LIKE LOWER(?)"}
      contacts_conditions = [contacts_conditions.join(" AND ")] + query_tokens
      contacts_conditions
    end

    def collect_contact_data(contact)
      data = []
      data << contact_path(contact)
      data << (contact.company ? contact.company.name : "")
      data << contact.tags.collect{|tag| tag.name}
      data
    end

    def get_tags_query_conditions(query_tokens)
      tags_conditions = []
      query_tokens.size.times{tags_conditions << "LOWER(#{Tag.table_name}.name) LIKE LOWER(?)"}
      tags_conditions = [tags_conditions.join(" OR ")] + query_tokens
      tags_conditions
    end

    def merge_conditions(conditions1, conditions2)
      conditions1 = clean_conditions(conditions1)
      conditions2 = clean_conditions(conditions2)

      conditions = conditions1.dup
      if conditions2.size > 0
        conditions[0] = "("+conditions.first+") OR (" + conditions2.first + ")"
        conditions += conditions2[1..-1] if conditions2.size > 1
      end

      conditions
    end

    def clean_conditions(conditions)
      conditions = [] if conditions.nil?
      conditions = [conditions] unless conditions.is_a?(Array)
      conditions.collect{|condition| condition.to_s}
    end

    def get_joins_query_string
      c_tn = Contact.table_name
      ct_tn = ContactTag.table_name
      t_tn = Tag.table_name
      %(LEFT JOIN "#{ct_tn}" ON "#{c_tn}"."id" = "#{ct_tn}"."contact_id" LEFT JOIN "#{t_tn}" ON "#{t_tn}"."id" = "#{ct_tn}"."tag_id")
    end

    def get_select_query_string
      %(DISTINCT "#{Contact.table_name}".*)
    end

    def execute_query(conditions)
      query = Contact.select(get_select_query_string)
      query = query.joins(get_joins_query_string)
      query = query.includes(:company, :tags)
      query = query.where(conditions)
      query = query.order("#{Contact.table_name}.name")
      contacts = query.all(:readonly => true)
    end
  end
end
