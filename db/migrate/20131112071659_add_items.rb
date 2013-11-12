class AddItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :title
      t.text :details
    end
  end
end
