require 'will_paginate'
module Zable
  module ActiveRecord

    module ClassMethods

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

      def scoped_for_paginate(params, scoped_object, options)
        page_params = (params[:page] || {}).stringify_keys
        paginate_opts = {}
        # params take preference over option, so that we may change page size on the frontend
        page_size = page_params['size'] || options[:per_page]
        paginate_opts[:page] = page_params['num'] || 1
        paginate_opts[:per_page] = page_size if page_size.present?

        scoped_object = scoped_object.paginate(paginate_opts) if scoped_object.respond_to?(:paginate)
        scoped_object
      end

      def populate(params={}, options = {})
        obj = scoped_for_sort(params, self)
        obj = scoped_for_search(params, obj)
        scoped_for_paginate(params, obj, options)
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
