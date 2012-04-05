class ItemsController < ActionController::Base

  def index
    @items = Item.populate(params)
    #:page => 1, :order => [ params[:sort][:attr], params[:sort][:order] ].join(" ")
  end

end
