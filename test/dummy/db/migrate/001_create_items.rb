class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items, :force => true do |t|
      t.string :string_column
      t.integer :integer_column
      t.string :string_column_2
      t.integer :integer_column_2
      t.string :string_column_3
      t.integer :integer_column_3
      t.date :date_column
      t.date :something_happened_on
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end