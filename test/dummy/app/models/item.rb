class Item < ActiveRecord::Base

  searchable :string_column, :integer_column, :integer_column_2, :something_happened_on
  sortable :string_column, :integer_column, :integer_column_2

  def some_method
    "value"
  end
end