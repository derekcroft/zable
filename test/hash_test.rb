require 'test_helper'

class HashTest < ActiveSupport::TestCase

  setup do
    @hash_with_empties = {:some_key => "some_value", :empty_key => nil, :blank_key => '', :another_key => "another_value"}
    @expected_hash = {:some_key => "some_value", :another_key => "another_value"}
  end

  test "hash responds to reject_empty_values" do
    assert_respond_to @hash_with_empties, :reject_empty_values
  end

  test "passing a hash with no empty values returns the same hash" do
    assert_equal @expected_hash.reject_empty_values, @expected_hash
  end

  test "passing a hash with empty values returns the hash without the empty values" do
    assert_equal @hash_with_empties.reject_empty_values, @expected_hash
  end

end