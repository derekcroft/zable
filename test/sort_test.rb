require 'test_helper'

class SortTest < ActiveSupport::TestCase

  setup do
    setup_sort_records
  end

  ## General sorting behavior
  test "sort params scope sorts the given attribute properly" do
    criteria = { 'attr' => 'key', 'order' => 'desc' }
    expected_results = Thing.sort_key('order' => 'desc').all
    assert_sort_params(criteria, expected_results)
  end

  test "sort scope named sort_attr is called" do
    criteria = { 'attr' => 'name', 'order' => 'asc' }
    expected_results = Thing.sort_name('order' => 'asc').all
    assert_sort_params(criteria, expected_results)
  end

  test "for_sort_params accepts symbols as keys" do
    criteria = { :attr => :name, :order => :desc }
    expected_results = Thing.sort_name('order' => 'desc').all
    assert_sort_params(criteria, expected_results)
  end

  test "individual sort scopes take symbols as keys" do
    criteria = { 'attr' => 'name', 'order' => 'desc' }
    expected_results = Thing.sort_name(:order => :desc).all
    assert_sort_params(criteria, expected_results)
  end

  test "sort order other than asc or desc defaults to asc" do
    criteria = { 'attr' => 'key', 'order' => 'asdfasdf' }
    expected_results = Thing.sort_key('order' => 'asc').all
    assert_sort_params(criteria, expected_results)
  end

  test "sortable creates scopes" do
    assert Item.respond_to?(:sort_string_column)
  end

  test "sortable creates scopes that sort by their column and a specified order" do
    # asserts that the relations are equal, not their results
    assert_equal Item.order("items.string_column "), Item.sort_string_column({})
    assert_equal Item.order("items.string_column DESC"), Item.sort_string_column(order: "DESC")
  end

  test "for_sort_params handles nil params gracefully" do
    assert_nothing_raised { Thing.for_sort_params(nil).all }
  end

  test "for_sort_params returns all records with nil params" do
    expected_results = Thing.all
    results = Thing.for_sort_params(nil).all
    assert_equal expected_results, results
  end

  ## Sort logic scenarios
  test "sorting by a string" do
    assert_sort @things, :key do |r|
      r.collect(&:key)
    end
  end

  test "sorting by a boolean" do
    assert_sort @things, :some_boolean do |r|
      r.collect { |c| c ? 1 : 0 }
    end
  end


  protected
  def setup_sort_records
    @things ||= [
        FactoryGirl.create(:thing, :key => "21", :some_boolean => true, :name => "jeff"),
        FactoryGirl.create(:thing, :key => "22", :some_boolean => false, :name => "rachel"),
        FactoryGirl.create(:thing, :key => "23", :some_boolean => true, :name => "andrew"),
        FactoryGirl.create(:thing, :key => "25", :some_boolean => false, :name => "jeff"),
        FactoryGirl.create(:thing, :key => "26", :some_boolean => true, :name => "drew"),
        FactoryGirl.create(:thing, :key => "11", :some_boolean => false, :name => "graham")
    ]
  end

  def assert_sort_params(criteria, expected_results)
    results = Thing.for_sort_params(criteria).all
    assert_not_nil expected_results
    assert_equal expected_results, results
  end

  def sort(expected_results, order)
    non_nilz, nilz = expected_results.partition {|e| e}
    sorted_non_nilz = order == :asc ? non_nilz.sort : non_nilz.sort.reverse
    sorted_non_nilz.concat nilz
  end

  def assert_sort(expected_results, attr, &block)
    scope_method = "sort_#{attr}".to_sym
    expected_results = yield(expected_results)

    criteria = {:attr => "#{attr}", :order => "ASC"}
    assert_expected_results scope_method, criteria, sort(expected_results, :asc), &block

    criteria[:order] = "DESC"
    assert_expected_results scope_method, criteria, sort(expected_results, :desc), &block
  end

  def assert_expected_results(scope_method, scope_argument, expected_results)
    results = Thing.send(scope_method, scope_argument).all
    results = yield(results) if block_given?
    assert_equal expected_results.size, results.size
    assert_equal expected_results, results
  end

end
