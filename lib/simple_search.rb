module SimpleSearch
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    
    def acts_as_simply_searchable(options = {})
      simple_search_options = options
      
      named_scope :simple_search, lambda { |query|
        unless query.blank?
          keywords = extract_keywords_from_query(query)
          fields = simple_search_options[:columns] ? Array(simple_search_options[:columns]) : self.column_names
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
        
        def self.simple_search_options
          @@simple_search_options
        end

        def self.simple_search_options=(options = {})
          @@simple_search_options = options
        end
        
    end
    alias :simply_searchable :acts_as_simply_searchable
    
  end
  
end

ActiveRecord::Base.send :include, SimpleSearch