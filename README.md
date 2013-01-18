# Zable

Zable lets you easily build sortable and searchable tables of your active record objects.

## Example

```ruby
# user.rb

# basic sortable behavior on attribute
sortable :name, :email, :created_at

# sort on a non-attribute
scope :sort_age, -> criteria { includes(:profile).order("profile.age #{criteria[:order]}") }
```

```ruby
# users_controller.rb

def index
  @users = User.populate(params)
end
```

```ruby
# index.html.erb

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
