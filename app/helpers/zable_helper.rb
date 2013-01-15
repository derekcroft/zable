module ZableHelper
  include Zable::WillPaginate

  def self.included(base)
    base.send :include, Zable::Html
  end

  def zable(collection, klass, args={}, &block)
    table = Zable::View.new(collection, klass, self, args, &block)
    table.render
  end

end
