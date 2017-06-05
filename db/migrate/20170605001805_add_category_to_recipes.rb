class AddCategoryToRecipes < ActiveRecord::Migration[5.0]
  def change
    add_reference :recipes, :category, foreign_key: true
  end
end
