class CreateRecipes < ActiveRecord::Migration[5.0]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :ingredients
      t.text :instructions
      t.float :suggested_weed
      t.float :suggested_portion
      t.string :video

      t.timestamps
    end
  end
end
