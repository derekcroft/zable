require 'test_helper'

class ColumnsTest < ActionView::TestCase

  ## test the helper method
  test "table has the expected headers" do
    collection = 2.times.collect { FactoryGirl.create :item }
    assert_header_cell_match {
      display_table collection, Item do
        column :string_column
        column :integer_column
        column :string_column_2
      end
    }
  end

  test "header cells title properly" do
    collection = 2.times.collect { FactoryGirl.create :item }
    t = display_table collection, Item do
      column :string_column
      column :integer_column, :title => "Overridden Integer"
    end
    assert_header_cell_regex_match "item-string-column", "String Column", t
    assert_header_cell_regex_match "item-integer-column", "Overridden Integer", t
  end

  test "header cell links to same page with sort parameters" do
    collection = 2.times.collect { FactoryGirl.create :item }
    t = display_table collection, Item do
      column :string_column
      column :integer_column
    end
    assert_match header_cell_with_sort_regex("item-string-column", "String Column", "string_column"), t
    assert_match header_cell_with_sort_regex("item-integer-column", "Integer Column", "integer_column"), t
  end

  test "header call with false sort does not contain a link" do
    collection = 2.times.collect { FactoryGirl.create :item }
    t = display_table collection, Item do
      column :integer_column, :sort => false
    end
    assert_no_match /<a href/, t, false
  end

  test "header call with false sort and title does not contain a link" do
    collection = 2.times.collect { FactoryGirl.create :item }
    t = display_table collection, Item do
      column :integer_column, :title => "Integer Column Header", :sort => false
    end
    assert_no_match /<a href/, t, false
  end

  ## test individual methods
  test "header row has a cell for each column specified" do
    assert_header_cell_match { table_header_cells Item, @COLUMNS }
  end

  test "header cells appear in the order specified" do
    th = table_header_cells Item, @COLUMNS
    cell_ids = th.scan(/<th[^<]id=['"]item-([^<]+)['"]>/).flatten.collect(&:underscore).collect(&:to_sym)
    assert_equal cell_ids, @COLUMNS.collect { |c| c[:name] }.collect(&:to_sym)
  end

  test "header cell ids are formatted like model-attribute" do
    col = {:name => "some_attribute"}
    id  = header_cell_id(Item, col)
    assert_match /item-some-attribute/, id
  end

  test "header cell titles default to titleized column name if not overridden" do
    assert_header_cell_title :integer_column, "item-integer-column", "Integer Column"
  end

  test "header cell titles use name attribute if present" do
    assert_header_cell_title "Overridden Name", ".*", "Overridden Name"
  end

  protected
  def assert_header_cell_match
    th = yield
    @COLUMNS.each do |ac|
      assert_match /<th[^>]+id=\"item-#{ac[:name].to_s.dasherize}\">/, th
    end
  end

  def assert_header_cell_regex_match(id, text, t)
    assert_match header_cell_regex(id, text), t
  end

  def assert_header_cell_title(name, id, text)
    th = table_header_cell Item, {:name => name}, @COLUMNS
    assert_header_cell_regex_match id, text, th
  end

  private
  def regex_prefix(id)
    "<th[^>]+id=\"#{id}\">[^<]*"
  end

  def regex_suffix(text)
    "#{text}.*<\/th>"
  end

  def regex(id, text, content)
    /#{regex_prefix(id)}#{content}#{regex_suffix(text)}/
  end
  
  def header_cell_regex(id, text, link=false)
    content = link ? "<a[^>]*>" : ""
    content << ".*"
    content = "#{content}<\/a>" if link
    regex id, text, content
  end

  def header_cell_with_sort_regex(id, text, name)
    regex id, text, '<a href=\"[^"]+sort\[attr\]='+name+'[^>]*>'
  end

end
