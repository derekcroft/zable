require 'test_helper'

class SearchTest < ActiveSupport::TestCase

  setup do
    setup_search_data
  end

  test "searching by multiple criteria" do
    search_params    = {:search => {:name => "jeff", :key => "25"}}
    search_results   = Thing.for_search_params(search_params[:search]).all
    expected_results = [@things[3]]

    assert_equal expected_results.size, search_results.size
    assert_equal search_results, expected_results
  end

  test "search with empty criteria" do
    search_params  = {:name => "", :key => "" }
    search_results = Thing.for_search_params(search_params).all

    assert_equal @things, search_results
  end

  test "search with no criteria" do
    search_results = Thing.for_search_params(nil).all

    assert_equal @things, search_results
  end

  test "scopes apply from hash tuple" do
    tuple = [:some_key, "some_value"]
    Thing.expects(:search_some_key).with("some_value")
    Thing.send(:scope_for_search_attribute, Thing, tuple)
  end

  test "injecting search scope rejects nonempty param values" do
    with_hashes do |hash|
      hash.expects(:reject_empty_values).returns({})
      Thing.send(:inject_search_scopes, hash)
    end
  end

  test "empty param hash does not inject search scopes" do
    with_hashes do |hash|
      hash.expects(:reject_empty_values).returns({})
      Thing.expects(:scope_for_search_attribute).never
      Thing.send(:inject_search_scopes, hash)
    end
  end

  test "searchable creates scopes" do
    assert Item.respond_to?(:search_string_column)
    assert Item.respond_to?(:search_integer_column)
    assert Item.respond_to?(:search_something_happened_on)
  end

  test "searchable creates scopes that test equality on a column" do
    # asserts that the relations are equal, not their results
    assert_equal Item.where(:string_column => "a"), Item.search_string_column("a")
  end

  test "searchable creates scopes that test date equality for attributes following the rails convention" do
    date = Date.today
    # asserts that the relations are equal, not their results
    assert_equal Item.where(:something_happened_on => date), Item.search_something_happened_on(date.to_s)
  end

  test "searchable creates scopes that test US-formatted date equality for attributes following the rails convention" do
    date = Date.today
    # asserts that the relations are equal, not their results
    assert_equal Item.where(:something_happened_on => date), Item.search_something_happened_on(date.strftime("%m/%d/%Y"))
  end

  protected
  def setup_search_data
    @things ||= [
        Factory(:thing, :key => "21", :name => "jeff"),
        Factory(:thing, :key => "22", :name => "rachel"),
        Factory(:thing, :key => "23", :name => "andrew"),
        Factory(:thing, :key => "25", :name => "jeff"),
        Factory(:thing, :key => "26", :name => "drew")
    ]
  end


  def setup_hashes
    hash          = {:some_key => "some_value", :empty_key => nil, :blank_key => '', :another_key => "another_value"}
    expected_hash = {:some_key => "some_value", :another_key => "another_value"}
    return hash, expected_hash
  end

  def with_hashes
    list = setup_hashes
    yield list
  end

end
