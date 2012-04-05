Factory.define :item do |i|
  i.sequence(:string_column) { |n| "String #{n}" }
  i.sequence(:integer_column) {|i| i }
  i.sequence(:integer_column_2) {|i| 30-i}
end
