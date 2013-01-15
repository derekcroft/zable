module ZableHelper
  include Zable::WillPaginate

  def self.included(base)
    base.send :include, Zable::Html
  end

  def zable(collection, klass, args={}, &block)
    table = Zable::View.new(collection, klass, self, args, &block)
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

end
