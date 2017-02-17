ActiveAdmin.register Recipe do
  permit_params :name, :ingredients, :instructions, :suggested_weed, :suggested_portion, :video
end
