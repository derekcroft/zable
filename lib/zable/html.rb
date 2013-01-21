module Zable
  module Html

    ## Table header methods
    def table_header(klass, columns)
      content_tag :thead do
        table_header_row(klass, columns)
      end
    end

    def table_header_row(klass, columns)
      content_tag :tr do
        table_header_cells(klass, columns)
      end
    end

    def table_header_cells(klass, columns)
      columns.inject("".html_safe) do |str, attr|
        str << table_header_cell(klass, attr, columns)
      end
    end

    def table_header_cell(klass, attr, columns)
      content_tag :th, :id => header_cell_id(klass, attr) do
        header_cell_content(attr, columns)
      end
    end

    def header_cell_content(attr, columns)
      if attr[:title] && attr[:title].instance_of?(Proc)
        attr[:title].call
      else
        str = link_to_if attr[:sort], header_cell_link_text(attr), header_cell_href(attr)
        str << header_cell_sort_image(attr)
      end
    end

    def header_cell_id(klass, attr)
      "#{idify klass.name}_#{idify attr[:name]}".html_safe
    end

    def current_url
      "#{controller.request.fullpath.split("?")[0]}"
    end

    def param(param_type, param_key, attr)
      "#{param_type}[#{param_key}]=#{attr}"
    end

    def sort_params(attr)
      params = []
      params << param(:sort, "attr", attr[:name])
      params << param(:sort, "order", attr[:sort_order]) if attr[:sorted?]
      params.join("&".html_safe)
    end

    def search_params(params)
      params.to_a.collect do |param|
        param(:search, param.first, param.second)
      end.join("&".html_safe)
    end

    def sort_arrow_image_file(attr)
      attr[:sort_order] == :desc ? "ascending.gif" : "descending.gif"
    end

    def header_cell_href(attr)
      all_params = [sort_params(attr), search_params(@search), (@_extra_params || {}).to_query.html_safe].reject(&:blank?).join("&".html_safe)
      current_url << "?".html_safe << all_params
    end

    def header_cell_link_text(attr)
      (attr[:title] || attr[:name].to_s.titleize).html_safe
    end

    def header_cell_sort_image(attr)
      return ''.html_safe unless attr[:sort] && attr[:sorted?]
      arrow = sort_arrow_image_file(attr)
      image_tag arrow
    end

    ## Table body methods
    def table_body(collection, columns, args)
      content_tag :tbody do
        return empty_table_body_row(columns,args) if collection.empty?
        (table_body_rows(collection, columns) || "".html_safe) + (args[:append] || "".html_safe)
      end
    end

    def empty_table_body_row(columns, args)
      content_tag :tr, :class => 'empty', :id=> "zable-empty-set" do
        content_tag :td, :colspan => columns.size do
          (args[:empty_message] || "No items found.").html_safe
        end
      end
    end

    def table_body_rows(collection, columns)
      collection.inject("".html_safe) do |str, elem|
        str << table_body_row(elem, columns)
      end
    end

    def table_body_row(elem, columns)
      content_tag :tr, :id => body_row_id(elem), :class => body_row_class do
        table_body_row_cells(elem, columns)
      end
    end

    def table_body_row_cells(elem, columns)
      columns.inject("".html_safe) do |str, ac|
        block = ac[:block] if ac.has_key?(:block)
        str << table_body_row_cell(ac, elem, &block)
      end
    end

    def table_body_row_cell(ac, elem)
      content_tag(:td, :id => body_cell_id(ac, elem)) do
        if block_given?
          yield elem
        else
          val = elem.send(ac[:name])
          val.respond_to?(:strftime) ? val.strftime("%m/%d/%Y") : val.to_s
        end
      end
    end

    def body_row_id(elem)
      "#{idify_class_name(elem)}_#{elem.id}".html_safe
    end

    def body_cell_id(ac, elem)
      "#{idify_class_name(elem)}_#{elem.id}_#{idify ac[:name]}".html_safe
    end

    def body_row_class
      cycle("odd", "even", name: "zable_cycle")
    end

    protected
    def idify_class_name(elem)
      idify elem.class.name
    end

    def idify(val)
      val.to_s.demodulize.underscore
    end

    def tag_args(args)
      tag_args = {}
      tag_args[:class] = args[:table_class].join(" ".html_safe) if args[:table_class] and !args[:table_class].empty?
      tag_args
    end

  end
end
