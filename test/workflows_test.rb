require_relative 'test_helper'

include ZableHelper

require 'will_paginate/view_helpers'

class WorkflowsTest < ActionDispatch::IntegrationTest

  setup do
    @items = [
      FactoryGirl.create(:item, :integer_column => 1, :integer_column_2 => 2),
      FactoryGirl.create(:item, :integer_column => 2, :integer_column_2 => 1),
      FactoryGirl.create(:item, :integer_column => 3, :integer_column_2 => 4),
      FactoryGirl.create(:item, :integer_column => 4, :integer_column_2 => 3),
      FactoryGirl.create(:item, :integer_column => 5, :integer_column_2 => 5)
    ]
  end

  ## Sorting tests
  def assert_sort(params={})
    get "/items", {
      :sort => {
        :attr => params[:attr], :order => params[:order]
      },
      :page => {
        :size => '1000', :num => '1'
      }
    }
    assert_response :success
    assert_not_nil assigns[:items]
    assert_equal assigns[:items], @items.reverse
  end

  def items_in_order(order)
    order.map {|pos| @items[pos]}
  end

  def click_header_link(attr)
    click_link("table th[data-column=#{attr}] a")
  end


  ## Pagination tests

  # Standard behavior
  test "specifying a page number and size to index request" do
    LinkWithParamsRenderer.any_instance.stubs(:to_html).returns('')
    get "/items", :page => { :num => 2, :size => 2 }
    assert_equal assigns[:items], @items[2..3]
  end

  ## Default cases
  test "sorting without a sort attribute defaults to first column" do
    #get "/items", :sort => { :order => "DESC" }
    #flunk
  end

  test "sorting without a sort order defaults to ascending" do
    Item.per_page = 100
    get "/items", :sort => { :attr => "integer_column_2" }
    assert_equal assigns[:items], items_in_order([1,0,3,2,4])
  end

  test "paging without a page number defaults to page 1" do
    LinkWithParamsRenderer.any_instance.stubs(:to_html).returns('')
    get "/items", :page => { :size => 2 }
    assert_equal assigns[:items], @items[0..1]
  end

  ## Link cases
  test "column headers are links to sort by that column" do
    get "/items"
    assert_response :success
    assert_select "table th[data-column=string_column] a"
  end

  test "column header sorts by opposite direction when clicked" do
    get "/items", :sort => { :attr => "integer_column", :order => "asc" }
    click_header_link("integer_column")
    assert_equal assigns[:items], @items.reverse
  end

  test "column header arrow points down when column is sorted ascending" do
    get "/items", :sort => { :attr => "integer_column_2", :order => "asc" }
    assert_select "table th[data-column=integer_column_2] img" do |elem|
      assert_match /src=\".*ascending.*\"/, elem[0].to_s
    end
  end

  test "column header arrow points up when column is sorted descending" do
    get "/items", :sort => { :attr => "integer_column_2", :order => "desc" }
    assert_select "table th[data-column=integer_column_2] img" do |elem|
      assert_match /src=\".*descending.*\"/, elem[0].to_s
    end
  end

  test "no column header arrow when column is not sorted" do
    get "/items", :sort => { :attr => "integer_column", :order => "desc" }
    assert_select "table th[data-column=integer_column_2] img", false
  end

  test "next page link takes you to the next page" do
    get "/items", :page => { :num => 1, :size => 2 }
    click_link("a.next_page")
    assert_equal @controller.params[:page][:num], '2'
  end

  test "previous page link takes you to the previous page" do
    get "/items", :page => { :num => 3, :size => 2 }
    click_link("a.previous_page")
    assert_equal @controller.params[:page][:num], '2'
  end

  # State change cases
  test "sort order and column are preserved when going to another paginated page" do
    get "/items",
        :sort => { :attr => "integer_column_2", :order => "desc" },
        :page => { :num => 1, :size => 2 }
    click_link("a.next_page")
    assert @controller.params[:sort].present?
    assert_equal @controller.params[:sort][:attr], "integer_column_2"
  end

  test "search params are preserved when sorting on a column" do
    get "/items",
        :sort => { :attr => "integer_column", :order => "desc" },
        :search => { :integer_column => '3' }
    click_header_link("integer_column_2")
    assert_equal @controller.params[:search][:integer_column], '3'
  end

  test "page 1 is returned when sort order or column is changed" do
    Item.per_page = 2
    get "/items",
        :page => { :num => 2 }
    click_header_link("integer_column_2")
    assert_equal assigns[:items].collect(&:integer_column_2), items_in_order([1,0]).collect(&:integer_column_2)
  end

  # link_sort_order helper tests
  test "link_sort_order sets new page size in params" do
    sort_params = { :attr => "integer_column_2", :order => "desc" }
    search_params = {:integer_column => '3' }
    get "/items",
        :sort => sort_params,
        :search => search_params,
        :page => { :num => 1, :size => 2 }
    click_link("#view_5_items")
    assert_equal @controller.params[:sort], sort_params.stringify_keys
    assert_equal @controller.params[:search], search_params.stringify_keys
    assert_equal @controller.params[:page], { :num => '1', :size => '5' }.stringify_keys
  end

  test "link_sort_order link shows all records when passed nil page_size" do
    get "/items",
        :page => { :num => 1, :size => 2 }
    click_link("#view_all_items")
    assert_equal @controller.params[:page][:size], 'all'
  end

  # Edge cases
  test "that call fails gracefully if you go to a nonexistent page" do
  end

  test "that call fails gracefully if you try to sort on a non-existent column" do
  end

  test "that call fails gracefully if you try to sort other than ASC or DESC" do
  end

  # Ajax
  test "that results can be obtained with AJAX" do
    xhr :get, "/items", {:sort => { :attr => "integer_column", :order => "desc"}}
    assert_response :success
    assert_not_nil assigns[:items]
    assert_select "table th[data-column=integer_column_2] img", false
  end

end
