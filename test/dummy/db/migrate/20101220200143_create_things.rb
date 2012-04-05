class CreateThings < ActiveRecord::Migration
  def self.up
    create_table :things, :force => true do |t|
      t.string :key, :name
      t.boolean :some_boolean
    end
  end

  def self.down
    drop_table :things
  end
end
