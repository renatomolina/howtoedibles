class RenameSuggestedWeed < ActiveRecord::Migration[5.2]
  def change
    rename_column :recipes, :suggested_weed, :suggested_quantity
  end
end
