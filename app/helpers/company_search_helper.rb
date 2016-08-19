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
        return []
      end

      data = companies.collect do |company|
        hash = {}
        hash[:label] = hash[:data] = company.name
        hash
      end
      data << {label: "Create new company for '#{search_string.strip}'", data: search_string.strip}

      data
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
