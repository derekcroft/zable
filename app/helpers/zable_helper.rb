module ZableHelper
  include Zable::WillPaginate

  def self.included(base)
    base.send :include, Zable::Html
  end

  def zable(collection, args={}, &block)
    table = Zable::View.new(collection, self, args, &block)
    table.render
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

  def set_page_size_path(page_size = nil)
    page_params = if page_size
      { :page => {:size => page_size, :num => 1} }
    else
      { :page => {:size => 'all'} }
    end
    current_path_with_params(params.slice(:sort, :search), page_params)
  end

end
