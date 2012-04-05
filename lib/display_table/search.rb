module DisplayTable
  module Search
    module ActiveRecord
      module ClassMethods
        def inherited(subclass)
          subclass.class_eval do
            scope :for_search_params, -> search_params { inject_search_scopes(search_params) }
          end
          super(subclass)
        end

        # Allows +Model.for_search_params+ to do equality-based searching for the given +attr_names+.
        # Date attributes (ending in "_on") will take Ruby-parseable date strings as well as the common
        # US case "mm/dd/yyyy".
        #
        #   searchable :first_name, :last_name, :born_on
        def searchable(*attr_names)
          attr_names.each do |attr_name|
            scope "search_#{attr_name}", -> attr_value do
              where(attr_name => (attr_name =~ /_on$/ ? parse_date_string(attr_value) : attr_value))
            end
          end
        end

        protected

        def inject_search_scopes(search_params)
          non_empty_search_params = search_params.try(:reject_empty_values) || {}

          non_empty_search_params.to_a.inject(self) { |result,value|
            scope_for_search_attribute(result, value)
          } unless non_empty_search_params.empty?
        end

        def parse_date_string(str)
          str =~ /\d\d\/\d\d\/\d{4}/ ? Date.strptime(str, '%m/%d/%Y') : str.to_date
        end
        
        def scope_name_for_attribute(type, attr)
          "#{type}_#{attr}".to_sym
        end

        def scope_for_search_attribute(target, tuple)
          attr = tuple.first
          target.send scope_name_for_attribute(:search, attr), tuple.second
        end

      end
    end
  end
end

ActiveRecord::Base.send :extend, DisplayTable::Search::ActiveRecord::ClassMethods
