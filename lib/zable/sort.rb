module Zable
  module Sort

    module ActiveRecord

      module ClassMethods
        def inherited(subclass)
          subclass.class_eval do
            def self.for_sort_params(sort_params)
              return self unless sort_params
              inject_sort_scope(sort_params)
            end
          end
          super(subclass)
        end

        # Allows +Model.for_sort_params+ to sort for the given +attr_names+ for the common sorting
        # case (i.e. "attr_name ASC" or "attr_name DESC")
        #
        #   sortable :last_name, :created_at
        def sortable(*attr_names)
          attr_names.each do |attr_name|
            scope "sort_#{attr_name}", -> ordering { order("#{table_name}.#{attr_name} #{ordering}") }
          end
        end

        protected

        def inject_sort_scope(sort_params)
          return unless sort_params
          sort_params.stringify_keys!
          sort_params['order'] = 'ASC' if sort_params['order'].nil? || sort_params['order'].upcase != "DESC"
          self.send scope_for_sort_attribute(sort_params), sort_params['order']
        end

        def scope_name_for_attribute(type, attr)
          "#{type}_#{attr}".to_sym
        end

        def scope_for_sort_attribute(sort_params)
          scope_name_for_attribute(:sort, sort_params['attr'])
        end
      end

    end

  end
end

ActiveRecord::Base.send :extend, Zable::Sort::ActiveRecord::ClassMethods
