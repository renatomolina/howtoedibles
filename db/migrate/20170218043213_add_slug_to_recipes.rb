class AddSlugToRecipes < ActiveRecord::Migration[5.0]
  def change
    add_column :recipes, :slug, :string, after: :name
  end
end
