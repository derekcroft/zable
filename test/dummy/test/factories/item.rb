FactoryGirl.define do 
  factory :item do
    sequence(:string_column) { |n| "String #{n}" }
    sequence(:integer_column) {|i| i }
    sequence(:integer_column_2) {|i| 30-i}
  end
end
