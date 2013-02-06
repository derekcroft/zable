class Thing < ActiveRecord::Base
  scope :sort_key, -> o { order("key #{o}") }
  scope :sort_name, -> o {}
  scope :sort_some_boolean, -> o { order("some_boolean #{o}") }

  scope :search_key, -> value { where( :key => value ) }
  scope :search_name, -> value { where(["upper(things.name) like ?", "%#{value.upcase}%"]) }
end