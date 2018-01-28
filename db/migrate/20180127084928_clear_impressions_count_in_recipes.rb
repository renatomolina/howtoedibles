class ClearImpressionsCountInRecipes < ActiveRecord::Migration[5.0]
  def change
    change_column :recipes, :impressions_count, :bigint
    Recipe.all.each { |recipe| recipe.update_attribute(:impressions_count, 0) }
  end
end
