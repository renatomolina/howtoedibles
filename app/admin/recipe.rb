ActiveAdmin.register Recipe do
  permit_params :name, :ingredients, :instructions,
                :suggested_weed, :suggested_portion, :video, :slug
  index do
    column :slug
    column :name
    column :suggested_weed
    column :suggested_portion
    column :video
    actions
  end
end
