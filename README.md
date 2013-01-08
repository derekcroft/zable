= Zable

## Example

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
