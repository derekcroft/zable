require 'test_helper'

class CellsTest < ActionView::TestCase

  def assert_cell_contains(value, cell)
    assert_match /<td[^>]*>#{value}<\/td>/, cell
  end

  test "helper returns a body cell for each attribute" do
    collection = 2.times.collect { FactoryGirl.create :item }
    html = zable collection, Item, &@COLUMN_PROC
    @COLUMNS.each do |c|
      assert_match /<tr[^<]*>.*<td[^>]+id=\"item_\d+_#{idify c[:name]}\">.*<\/td>.*<\/tr>/, html
    end
  end
  
  test "table row has a body cell for each attribute" do
    item = FactoryGirl.create :item
    html = table_body_row item, @COLUMNS
    @COLUMNS.each do |c|
      assert_match /<tr[^<]*>.*<td[^>]+id=\"item_\d+_#{idify c[:name]}\">.*<\/td>.*<\/tr>/, html
    end
    tds = html.scan(/<td[^<]+>/)
    assert_equal tds.size, @COLUMNS.size
  end

  test "cell value renders with a block if block is passed to helper" do
    collection = [ FactoryGirl.create(:item, :string_column => "Hello") ]
    html = zable collection, Item do
      column :string_column do |i|
        i.string_column.upcase + " - extra stuff"
      end
    end
    assert_cell_contains "HELLO - extra stuff", html
  end

  test "cell id is of the format singularmodel_id_attribute" do
  end

  test "cell value for string or integer attribute is the attribute value" do
    item = FactoryGirl.create :item, :string_column => "Hello", :integer_column => 7

    # assert correct string value
    col = {:name => "string_column"}
    html = table_body_row_cell col, item
    assert_cell_contains "Hello", html

    # assert correct integer value
    col = {:name => "integer_column"}
    html = table_body_row_cell col, item
    assert_cell_contains "7", html
  end

  test "cell value that is a date is formatted correctly" do
    item = FactoryGirl.create :item, :date_column => Date.new(2009, 12, 11)

    # assert correct date value
    col = {:name => "date_column"}
    html = table_body_row_cell col, item
    assert_cell_contains "12\/11\/2009", html
  end

  test "cell value renders with a block if block is given" do
    item = FactoryGirl.create :item, :string_column => "Hello"
    col = {:name => "string_column"}
    html = table_body_row_cell col, item do |i|
      i.string_column.upcase + " - extra stuff"
    end
    assert_cell_contains "HELLO - extra stuff", html
  end

  test "cell value renders if attribute is a method" do
    item = FactoryGirl.create :item
    Item.any_instance.expects(:some_method).returns("some_value")
    col = {:name => "some_method"}
    html = table_body_row_cell col, item
    assert_cell_contains "some_value", html
  end
  
end
