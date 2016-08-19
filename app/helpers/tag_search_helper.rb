module TagSearchHelper
  class << self
    def search_for_tags(search_string)
      unless search_string.blank?
        # split the keywords for the search:
        query_tokens = search_string.split(" ").collect{|token| "%"+token.gsub("%","").downcase+"%"}
        conditions = get_tags_query_conditions(query_tokens)
        tags = execute_query(conditions)
      else
        return []
      end

      data = tags.collect do |tag|
        hash = {}
        hash[:label] = hash[:data] = tag.name
        hash
      end
      data << {label: "Create new tag named '#{search_string.strip}'", data: search_string.strip}

      data
    end

    private
    def get_tags_query_conditions(query_tokens)
      tags_conditions = []
      query_tokens.size.times{tags_conditions << "LOWER(#{Tag.table_name}.name) LIKE ?"}
      [tags_conditions.join(" AND ")] + query_tokens
    end

    def execute_query(conditions)
      query = Tag.where(conditions)
      query = query.order("#{Tag.table_name}.name")
      query = query.limit 9
      query.readonly
    end
  end
end
