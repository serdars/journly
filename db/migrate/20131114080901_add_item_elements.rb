class AddItemElements < ActiveRecord::Migration
  def change
    create_table :item_elements do |t|
      t.string :element_type
      t.string :name
      t.text :data
      t.belongs_to :item
    end
  end
end
