class Thing < ActiveRecord::Base
  scope :sort_key, -> criteria { order("key #{criteria[:order]}") }
  scope :sort_name, -> criteria {}
  scope :sort_some_boolean, -> criteria { order("some_boolean #{criteria[:order]}") }

  scope :search_key, -> value { where( :key => value ) }
  scope :search_name, -> value { where(["upper(things.name) like ?", "%#{value.upcase}%"]) }
end