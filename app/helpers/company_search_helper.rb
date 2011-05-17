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
      hash[:suggestions] = companies.collect{|c| c.name}
      hash[:data] = companies.collect{|company| company.id}

      unless search_string.blank?
        name = search_string.strip
        new_company_id = [9, companies.size].min
        hash[:suggestions].insert(new_company_id, "Create a new company entry for '#{name}'")
        hash[:data].insert(new_company_id, "")
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
      Company.joins("LEFT JOIN contacts ON companies.id = contacts.company_id").where(:contacts => {:id => nil}).destroy_all
    end

    def execute_query(conditions)
      query = Company.where(conditions)
      query = query.order("#{Company.table_name}.name")
      query.all(:readonly => true)
    end
  end
end
