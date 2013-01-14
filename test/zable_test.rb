require_relative 'test_helper'

class ZableTest < ActionView::TestCase

  ## Test helpers for this gem
  def assert_html_table(collection)
    assert_match /<table.*>.*<\/table>/, zable(collection, Item, &@COLUMN_PROC)
  end

  def null_object
    mock_scope = mock('scoped object')
    mock_scope.stub_everything
    mock_scope
  end

  ## test that the plugin is loaded properly
  test "modules exist in the current scope" do
    assert_kind_of Module, Zable
    assert_kind_of Module, Zable::Html
    assert_kind_of Module, Zable::Sort
    assert_kind_of Module, Zable::Sort::ActiveRecord
    assert_kind_of Module, Zable::ActiveRecord
    assert_kind_of Module, Zable::ActiveRecord::ClassMethods::Helpers
    assert_kind_of Module, Zable::WillPaginate
    assert_kind_of Module, ZableHelper
  end

  ## test overall functionality of plugin
  test "helper method can be called with an empty collection" do
    collection = []
    assert_nothing_raised { zable collection, Item, &@COLUMN_PROC }
  end

  # this is important if you want to have columns hidden based on a condition:
  # zable(@complaints, Complaint) do
  #   column(:delete, sort: false) {|c| link_to("Delete", "#") } if permitted_to?(:delete, :complaints)
  # end
  test "helper method can be called with a block that returns nil" do
    collection = 2.times.collect { FactoryGirl.create :item }
    assert_nothing_raised { zable collection, Item, &@COLUMN_PROC_RETURNING_NIL }
  end

  test "empty_table_body_row called when collection is empty" do
    collection = []
    ZableTest.any_instance.expects(:empty_table_body_row)
    zable collection, Item, &@COLUMN_PROC
  end

  test "empty table body row creates a tr with a td" do
    columns = []
    @rendered = empty_table_body_row(columns, {})
    assert_select "#zable-empty-set"
  end

  test "empty table body row creates a td with default message" do
    columns = []
    @rendered = empty_table_body_row(columns, {})
    assert_select 'td', "No items found.".html_safe
  end

  test "empty table body row creates a td with custom message if arg empty_message is set" do
    columns = []
    args={empty_message: 'nothin to display'}
    @rendered = empty_table_body_row(columns,args)
    assert_select 'td', args[:empty_message].html_safe
  end

  # plugin adds "populate" method to models
  test "populate method" do
    assert_respond_to Item, :populate
  end

  test "populate method passes page value and size to paginate method" do
    Item.expects(:paginate).with(has_entries(:page => 2, :per_page => 3))
    Item.populate :page => {:num => 2, :size => 3}
  end

  test "populate method invokes for_sort_params if sort params present in request" do
    Item.expects(:for_sort_params).with(has_entries('attr' => "string_column", 'order' => "desc")).returns(null_object)
    Item.populate :sort => {:attr => "string_column", :order => "desc"}
  end

  test "populate method does not invoke for_sort_params if sort params absent from request" do
    Item.expects(:for_sort_params).never
    Item.populate
  end

  test "populate method invokes for_search_params if search params present in request" do
    Item.expects(:for_search_params).with(has_entries('string_column' => 'search string')).returns(null_object)
    Item.populate :search => {:string_column => 'search string'}
  end

  test "populate method does not invoke for_search_params if search params absent from request" do
    Item.expects(:for_search_params).never
    Item.populate
  end

  # given a block, helper populates columns array
  test "columns populate from block" do
    col = columns do
      column :col_1
      column :col_2
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
  end

  test "column stores block value passed to it" do
    col = columns do |c|
      column :col_1 do |i|
        i.string_column.upcase + " - extra stuff"
      end
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_kind_of Proc, column[:block]
  end

  test "column stores title passed to it" do
    col = columns do |c|
      column :col_1, :title => "Col 1 Title"
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_equal "Col 1 Title", column[:title]
  end

  test "column stores sort value passed to it" do
    col = columns do |c|
      column :col_1, :sort => false
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_equal false, column[:sort]
  end

  test "sort value for column defaults to true" do
    col = columns do |c|
      column :col_1
    end
    column = col[0]
    assert_kind_of Hash, column
    assert_equal :col_1, column[:name]
    assert_equal true, column[:sort]
  end

  # helper called with a non-empty collection
  test "main helper method returns an html table" do
    collection = 2.times.collect { FactoryGirl.create :item }
    assert_html_table collection
  end

  # helper called with table classes
  test "html table can have additional classes" do
    collection    = 2.times.collect { FactoryGirl.create :item }
    table_classes = ["wmg-result-list", "hrca-table"]
    html          = zable collection, Item, :table_class => table_classes, &@COLUMN_PROC
    table_classes.each do |tc|
      assert_match /<table.+class=['"].*#{tc}.*['"]>.*<\/table>/, html
    end
  end

  test "header links merge in extra params that are passed" do
    columns = []
    columns.instance_variable_set(:@_extra_params, {:useful => "stuff", :to_pass => "as params"})
    href = header_cell_href({:name => "awesome", :sort_order => "desc"}, columns)
    assert_match /[\?&]useful=stuff(&|$)/, href
    assert_match /[\?&]to_pass=as\+params(&|$)/, href
  end

  test "zable passes entry_name on to the pagination links" do
    collection = 2.times.map { FactoryGirl.create :item }
    expects(:page_entries_info).twice.with(collection, {:entry_name => 'dealy'}).returns("")
    stubs :will_paginate => ""
    zable(collection, Item, :paginate => true, :entry_name => 'dealy', &@COLUMN_PROC)
  end

  test "zable passes params on to the pagination links" do
    params = {:awesome => :tastic}
    collection = 2.times.collect { FactoryGirl.create :item }
    WillPaginate::LinkWithParamsRenderer.expects(:new).with(params).at_least_once
    self.stubs(:page_entries_info => "", :will_paginate => "")
    zable(collection, Item, :paginate => true, :params => params, &@COLUMN_PROC)
  end

  test "zable can append a string before the closing tbody tag" do
    collection = 2.times.collect { FactoryGirl.create :item }
    appended = "<tr><td>Appended!</td></tr>"
    html = zable(collection, Item, :append => appended.html_safe, &@COLUMN_PROC)
    assert_match /#{appended}\s*<\/tbody>/, html
  end

  ## test functionality of individual methods
  test "helper method returns html table" do
    collection = []
    assert_html_table collection
  end

  test "list all non-Rails attributes on a model" do
    assert_respond_to Item, :attribute_columns_only
    assert_equal ["integer_column", "string_column",
                  "integer_column_2", "string_column_2",
                  "integer_column_3", "string_column_3",
                  "date_column", "something_happened_on"].sort,
                 Item.attribute_columns_only.sort
  end

  test "sort order of non-sorted column is nil" do
    self.expects(:sorted_column?).returns(false)
    assert_nil link_sort_order(:col_1)
  end

  test "link sort order is :desc if current sort order is :asc" do
    self.expects(:sorted_column?).with(:col_1).returns(true)
    self.expects(:current_sort_order).returns(:desc)
    assert_equal :asc, link_sort_order(:col_1)
  end

  test "link sort order is :asc if current sort order is :desc" do
    self.expects(:sorted_column?).with(:col_1).returns(true)
    self.expects(:current_sort_order).returns(:asc)
    assert_equal :desc, link_sort_order(:col_1)
  end

end
