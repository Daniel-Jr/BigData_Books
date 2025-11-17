class CreateScrapings < ActiveRecord::Migration[8.1]
  def change
    create_table :scrapings do |t|
      t.integer :store
      t.string :link
      t.string :title
      t.float :price, precision: 10, scale: 2
      t.references :search, null: false, foreign_key: true
      t.timestamps
    end
  end
end
