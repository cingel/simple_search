module SimpleSearch
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    
    def acts_as_simply_searchable(options = {})
      @@simple_search_columns = options[:columns] ? Array(options[:columns]) : self.column_names
      named_scope :simple_search, lambda { |query|
        unless query.blank?
          keywords = extract_keywords_from_query(query)
          fields = @@simple_search_columns
          keyword_conditions = []
          keywords.each do |keyword|
            keyword_condition = fields.collect { |field_name| "#{self.table_name}.#{field_name} LIKE '%#{keyword}%'" }.join(' OR ')
            keyword_conditions.push("(#{keyword_condition})")
          end
          conditions = keyword_conditions.join(' AND ')
          { :conditions => conditions }
        end
      }
      private
        def self.extract_keywords_from_query(query)
          query.to_s.gsub(',', ' ').split(' ').collect { |keyword| keyword.strip }
        end
    end
    
  end
  
end

ActiveRecord::Base.send :include, SimpleSearch