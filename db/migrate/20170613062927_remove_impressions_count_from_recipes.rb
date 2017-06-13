class RemoveImpressionsCountFromRecipes < ActiveRecord::Migration[5.0]
  def change
    remove_column :recipes, :impressions_count
  end
end
