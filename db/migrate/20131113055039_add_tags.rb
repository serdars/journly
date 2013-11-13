class AddTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end
 
    create_table :items_tags do |t|
      t.belongs_to :item
      t.belongs_to :tag
    end
  end
end
