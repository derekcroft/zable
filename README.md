# Zable

Zable lets you easily build sortable and searchable tables of your active record objects.

## zable view helper

The zable helper method will render the actual table in your view.

```ruby
zable collection, options = {} do
  # define columns
end
```

* **collection** - (Array) An array of active_record objects
* **options** - (Hash)
  * **:class** - (String) Html class
  * **:id** - (String) Html id
  * **:params** - (Hash) Additional params to be appended at the end of every header/pagination link

Within the zable block, you can use the `column` method to define the columns of your table.

```ruby
column(attribute, options={})
column(attribute, options={}, &block)

# example
zable @items do
  column :column_1
  column :column_2 {|item| item.to_s}
end
```

* **attribute** - (Symbol) Name of the attribute on the active_record object for this column. When no block is supplied, this will be the content of this column.
* **options** - (Hash)
  * **:title** - (String or Proc) You can use this to designate a custom header title string, or with a proc, supply completely custom header markup.
  * **:sort** - (Boolean, default: true) By default, the header title will be a link that can be used to sort its respective column. However by setting this option to false, the title will not be a link.

If you pass in a block, the content of each cell in that column will be calculated from the block; otherwise the content will be taken from the supplied attribute.

## In the controller

The zable gem provides a single `populate` method to handle sorting, searching/filtering, and pagination. Querying your objects is as simple as this:

```ruby
def index
  @items = Item.populate(params)
  # or
  @items = current_user.items.populate(params)
end
```

As you can see, all me must do is pass in the request's params to the `populate` method. You can also attach the method after a chain of queries.

Below shows an example of all possible passed parameters of interest when using sorting, searching and pagination:

```ruby
params = {
  sort: {
    attr: "column_1", # name of the sorted attribute
    order: "asc" # 'asc' or 'desc' ('asc' is default)
  },
  search: {
    column_1: "some_search", # key is the attr being searched on, value is the search query
    column_2: "some_other_search"
  },
  page: {
    num: 1, # page number
    size: 20 # items per page
  }
}
```

## Sorting

You can easily sort on your models' column attributes via the `sortable` method provided on ActiveRecord.

```ruby
class Item < ActiveRecord::Base
  sortable :name, :price, :created_at
end

# in the view
zable @items do
  column(:name)
  column(:price)
  column(:created_at)
end
```

If you want to sort on something more complex than a column in your database, you can do so by creating a named scope:

```ruby
class Item < ActiveRecord::Base
  scope :sort_category, -> criteria { includes(:category).order("category.name #{criteria[:order]}") }
end

# in the view
zable @items do
  column(:category)
end
```

## Searching

Similar to sorting, zable provides a `searchable` method on ActiveRecord.

```ruby
class Item < ActiveRecord::Base
  searchable :name, :price, :created_at
end
```

This allows us to do equality-based searching on these attributes. Again, if you would like to do something more complex, create a named scope:

```ruby
class Item < ActiveRecord::Base
  scope :search_category, -> value { joins(:category).where("upper(items.category) like %#{value.upcase}%") }
end
```

## Pagination

Optionally, you can use pagination via [will_paginate](https://github.com/mislav/will_paginate). In the view, simply set the 'paginate' option:

```ruby
zable @items, paginate: true do
  ...
end
```

As with will_paginate, page size can be set on your model:

```ruby
class Item
  self.per_page = 10
end
# OR
WillPaginate.per_page = 10
```

Additionally, you can set a per_page option directly in the #populate method:

```ruby
@items = Item.populate(params, per_page: 20)
```

Lastly, if you have a page size set in the params, this will override any of the previous per_page settings.

```ruby
params['page']['size'] = 15 # this takes precedence over any other settings
```

This allows your users to set how many items are shown per page on the front end. To help with this, zable provides a `set_page_size_path(page_size)` helper method. In your view, you can do something like this:

```ruby
<%= link_to "View 10 per page", set_page_size_path(10) %>
<%= link_to "View all items", set_page_size_path() %>
```

As shown above, a nil page_size can be used for showing all items on a single page.

## Example

user.rb:
```ruby
# basic sortable behavior on attribute
sortable :name, :email, :created_at

# sort on a non-attribute
scope :sort_age, -> criteria { includes(:profile).order("profile.age #{criteria[:order]}") }
```

users_controller.rb:
```ruby
def index
  @users = User.populate(params)
end
```

index.html.erb:
```erb
<%= 
  zable @items, class: "users-table" do
    column(:name)
    column(:email)
    column(:created_at, :title => "Join Date")
    column(:age) {|user| user.profile.age}
    column(:edit, :title => "") {|user| link_to "Edit", edit_user_path(user)}
  end
%>
```
