class AddPositionToRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :recipes, :position, :integer, default: 1
  end
end
