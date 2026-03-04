ActiveAdmin.register Category, as: 'Category' do
  config.filters = false

  permit_params :name, :slug
end
