module CompanySearchHelper
  class << self
    def search_for_companies(search_string)
      clean_companies_without_contacts
      unless search_string.blank?
        # split the keywords for the search:
        query_tokens = search_string.split(" ").collect{|token| "%"+token.gsub("%","").downcase+"%"}
        conditions = get_companies_query_conditions(query_tokens)
        companies = execute_query(conditions)
      else
        companies = []
      end

      hash = {}
      hash[:query] = search_string

      companies_names = companies.collect{|c| c.name}

      if companies_names.size == 1 and companies_names.first == search_string
        hash[:suggestions] = hash[:data] = []
      else
        hash[:suggestions] = (hash[:data] = companies_names).dup

        unless search_string.blank?
          name = search_string.strip
          new_company_id = [9, companies.size].min
          hash[:data].insert(new_company_id, name)
          hash[:suggestions].insert(new_company_id, "Create new company for '#{name}'")
        end
      end

      hash
    end

    private
    def get_companies_query_conditions(query_tokens)
      companies_conditions = []
      query_tokens.size.times{companies_conditions << "LOWER(#{Company.table_name}.name) LIKE ?"}
      [companies_conditions.join(" AND ")] + query_tokens
    end

    def clean_companies_without_contacts
      Company.joins("LEFT JOIN contacts ON companies.id = contacts.company_id").where(:contacts => {:id => nil}).readonly(false).destroy_all
    end

    def execute_query(conditions)
      query = Company.where(conditions)
      query = query.order("#{Company.table_name}.name")
      query = query.limit 9
      query.readonly
    end
  end
end
