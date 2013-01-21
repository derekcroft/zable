# Zable

Zable lets you easily build sortable and searchable tables of your active record objects.

## zable view helper

The zable helper method will render the actual table in your view.

```ruby
zable collection, klass, options = {} do
  # define columns
end
```

* **collection** - (Array) An array of active_record objects
* **klass** - (Class) Class of the acive_record objects in the collection. This is needed for the case when collection is empty.
* **options** - (Hash)
  * **:class** - (String) Html class
  * **:id** - (String) Html id

Within the zable block, you can use the `column` method to define the columns of your table.

```ruby
column(attribute, options={})
column(attribute, options={}, &block)

# example
zable @items, Item do
  column :column_1
  column :column_2 {|item| item.to_s}
end
```

* **attribute** - (Symbol) Name of the attribute on the active_record object for this column. When no block is supplied, this will be the content of this column.
* **options** - (Hash)
  * **:title** - (String or Proc) You can use this to designate a custom header title string, or with a proc, supply completely custom header markup.
  * **:sort** - (Boolean, default: true) By default, the header title will be a link that can be used to sort its respective column. However by setting this option to false, the title will not be a link.


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
  zable @items, Item, :table_class => ["users-table", "shiny-colorful-table"] do
    column(:name)
    column(:email)
    column(:created_at, :title => "Join Date")
    column(:age) {|user| user.profile.age}
    column(:edit, :title => "") {|user| link_to "Edit", edit_user_path(user)}
  end
%>
```
