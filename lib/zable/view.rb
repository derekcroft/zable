module Zable

  class View
    include Zable::Html

    attr_reader :columns

    def initialize(collection, klass, template, options={}, &block)
      @collection = collection
      @klass = klass

      @template = template # this refers to the view context
      raise "Must pass in valid view context" unless @template.kind_of? ActionView::Context
      @search = @template.controller.request.params[:search]
      @_extra_params = options[:params]

      @options = options
      @columns = []
      instance_eval(&block)
    end

    def render
      reset_cycle("zable_cycle")

      html = ''.html_safe #stylesheet_link_tag("zable")
      html << pagination_element if @options[:paginate]
      html << zable_element
      html << pagination_element if @options[:paginate]
      html
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

      @columns << col
    end

    private

    def h
      @template
    end

    def method_missing(*args, &block)
      # missing methods will be sent to the view context - these will generally be rails helper methods
      h.send(*args, &block)
    end

    def zable_element
      content_tag(:table, tag_args(@options)) do
        table_header(@klass, @columns) << table_body(@collection, @columns, @options)
      end
    end

    def pagination_element
      content_tag :div, :class => 'brownFilterResultsBox' do
        page_entries_info(@collection, @options.slice(:entry_name)) <<
          will_paginate(@collection, :renderer => Zable::WillPaginate::LinkWithParamsRenderer.new(@options[:params] || {}))
      end
    end


  end

end