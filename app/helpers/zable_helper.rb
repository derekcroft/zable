module ZableHelper
  include Zable::WillPaginate

  def self.included(base)
    base.send :include, Zable::Html
  end

  def zable(collection, klass, args={}, &block)
    reset_cycle("zable_cycle")

    html = stylesheet_link_tag("zable")
    html << pagination_element(collection, args.slice(:entry_name, :params)) if args[:paginate]
    html << zable_element(args, block, collection, klass, args[:params])
    html << pagination_element(collection, args.slice(:entry_name, :params)) if args[:paginate]
    html
  end

  def zable_element(args, block, collection, klass, params)
    cols = columns(&block)
    cols.instance_variable_set :@search_params, controller.request.params[:search]
    cols.instance_variable_set :@_extra_params, params
    content_tag(:table, tag_args(args)) do
      table_header(klass, cols) << table_body(collection, cols, args)
    end
  end

  def pagination_element(collection, options)
    content_tag :div, :class => 'brownFilterResultsBox' do
      page_entries_info(collection, options.slice(:entry_name)) <<
        will_paginate(collection, :renderer => LinkWithParamsRenderer.new(options[:params] || {}))
    end
  end

  def columns
    controller.request.instance_variable_set :@zable_columns, []
    yield
    controller.request.instance_variable_get :@zable_columns
  end

  def sorted_column?(name)
    params[:sort][:attr] == name.to_s rescue false
  end

  def current_sort_order
    params[:sort][:order].downcase.to_sym rescue :asc
  end

  def link_sort_order(name)
    return nil unless sorted_column?(name)
    current_sort_order == :desc ? :asc : :desc
  end

  def column(name, options={}, &block)
    col = {
        :name       => name,
        :title      => options[:title],
        :sort       => options.has_key?(:sort) ? options[:sort] : true,
        :block      => block,
        :sorted?    => sorted_column?(name),
        :sort_order => link_sort_order(name)
    }

    zable_columns = controller.request.instance_variable_get :@zable_columns
    zable_columns << col
  end

end
