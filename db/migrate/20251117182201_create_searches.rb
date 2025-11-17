class CreateSearches < ActiveRecord::Migration[8.1]
  def change
    create_table :searches do |t|
      t.string :term
      t.timestamps
    end
  end
end
