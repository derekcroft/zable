module Zable
  module ActiveRecord

    module ClassMethods
      PAGE_DEFAULTS = { 'num' => 1, 'size' => 2 }

      def scoped_for_sort(params, scoped_object)
        hash = (params[:sort] || {}).stringify_keys
        scoped_object = scoped_object.for_sort_params(hash) unless hash.empty?
        scoped_object
      end

      def scoped_for_search(params, scoped_object)
        hash = (params[:search] || {}).stringify_keys
        scoped_object = scoped_object.for_search_params(hash) unless hash.empty?
        scoped_object
      end

      def scoped_for_paginate(params, scoped_object)
        page = (PAGE_DEFAULTS.merge(params[:page] || {})).stringify_keys
        scoped_object.paginate :page => page['num'], :per_page => page['size']
      end

      def populate(params={})
        obj = scoped_for_sort(params, self)
        obj = scoped_for_search(params, obj)
        scoped_for_paginate(params, obj)
      end

      module Helpers
        def attribute_columns_only
          self.column_names.reject { |c|
            is_foreign_key?(c) || is_rails_column?(c)
          }
        end

        protected
        def is_foreign_key?(column_name)
          !(self.reflect_on_all_associations(:belongs_to).detect do |e|
            if (e.options.has_key? :foreign_key)
              e.options[:foreign_key] == column_name
            else
              "#{e.name}_id" == column_name
            end
          end.nil?)
        end

        def is_rails_column?(column_name)
          %w{id created_at updated_at}.include?(column_name)
        end
      end
    end

  end

end

ActiveRecord::Base.send :extend, Zable::ActiveRecord::ClassMethods
ActiveRecord::Base.send :extend, Zable::ActiveRecord::ClassMethods::Helpers
