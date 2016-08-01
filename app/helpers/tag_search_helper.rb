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

      if tags_names.size == 1 and tags_names.first == search_string
        hash[:suggestions] = hash[:data] = []
      else
        hash[:suggestions] = (hash[:data] = tags_names).dup

        name = search_string.strip

        unless search_string.blank?
          name = search_string.strip
          new_tag_id = [9, tags.size].min
          hash[:data].insert(new_tag_id, name)
          hash[:suggestions].insert(new_tag_id, "Create new tag named '#{name}'")
        end
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
      query = query.limit 9
      query.readonly
    end
  end
end
