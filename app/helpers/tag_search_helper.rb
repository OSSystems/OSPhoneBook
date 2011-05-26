module TagSearchHelper
  class << self
    def search_for_tags(search_string)
      unless search_string.blank?
        # split the keywords for the search:
        query_tokens = search_string.split(" ").collect{|token| "%"+token.gsub("%","").downcase+"%"}
        conditions = get_tags_query_conditions(query_tokens)
        tags = execute_query(conditions)
      else
        tags = []
      end

      hash = {}
      hash[:query] = search_string

      tags_names = tags.collect{|c| c.name}
      tags_ids = tags.collect{|tag| tag.id}

      hash[:suggestions] = tags_names
      hash[:data] =  tags_ids

      name = search_string.strip

      unless search_string.blank? or hash[:suggestions].include?(name)
        hash[:suggestions].unshift name
        hash[:data].unshift ""
      end

      hash
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
      query.all(:readonly => true)
    end
  end
end
