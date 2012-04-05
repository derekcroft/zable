require 'test_helper'

class RowsTest < ActionView::TestCase

  def assert_body_rows(collection)
    tbody = yield
    collection.each do |i|
      assert_match /<tbody>.*<tr[^>]+id="item-#{i[:id]}"/, tbody
    end
  end

  test "html table body has a row for each element in the collection" do
    collection = 2.times.collect { FactoryGirl.create :item }
    assert_body_rows(collection) { display_table collection, Item, &@COLUMN_PROC }
  end

  test "table rows alternate odd and even" do
    collection = 3.times.collect { FactoryGirl.create :item }
    html       = display_table collection, Item, &@COLUMN_PROC
    html.scan(/<tr[^>]+class="([^"])"/).flatten.each_with_index do |c, i|
      assert_equal c, i.odd? ? "odd" : "even"
    end
  end

  test "helper returns a body cell for each attribute" do
    collection = 2.times.collect { FactoryGirl.create :item }
    html = display_table collection, Item, &@COLUMN_PROC
    @COLUMNS.each do |c|
      assert_match /<tr[^<]*>.*<td[^>]+id=\"item-\d+-#{idify c[:name]}\">.*<\/td>.*<\/tr>/, html
    end
  end
  
  test "table row has a body cell for each attribute" do
    item = FactoryGirl.create :item
    html = table_body_row item, @COLUMNS
    @COLUMNS.each do |c|
      assert_match /<tr[^<]*>.*<td[^>]+id=\"item-\d+-#{idify c[:name]}\">.*<\/td>.*<\/tr>/, html
    end
    tds = html.scan(/<td[^<]+>/)
    assert_equal tds.size, @COLUMNS.size
  end

  test "table body has a row for each element in the collection" do
    collection = 2.times.collect { FactoryGirl.create :item }
    assert_body_rows(collection) { table_body collection, @COLUMNS, {} }
  end

  test "table row id is of the format singularmodel-id" do
    item = FactoryGirl.create :item, :id => 15
    assert_match /<tr[^>]+id="item-15">.*<\/tr>/, table_body_row(item, @COLUMNS)
  end

end
