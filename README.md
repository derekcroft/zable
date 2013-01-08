## Example

```ruby
# item.rb

# basic sortable behavior
sortable :name, :color

# nontrivial sort by association
scope :sort_owner_name, -> criteria { includes(:owner).order("owner.name #{criteria[:order]}") }
```

```ruby
# items_controller.rb

def index
  @items = Item.populate(params)
end
```

```ruby
# index.html.erb

<%= 
  zable @items, Item, :table_class => ["items-table", "shiny-colorful-table"] do
    column(:name)
    column(:color)
    column(:owner_name) { |item| item.owner.name }
  end
%>
```
