class AddItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.text :details

      t.timestamps
    end
  end
end
