ActiveAdmin.register Recipe do
  config.filters = false

  permit_params :name, :ingredients, :instructions, :category_id,
                :suggested_weed, :suggested_portion, :video, :slug,
                :photo, :description
  index do
    column :slug
    column :name
    column :description
    column :suggested_weed
    column :suggested_portion
    column :video
    column :category_id
    actions
  end

  form do |f|
    f.inputs "Recipe" do
      tabs do
        tab 'Basic' do
          f.inputs "Basic" do
            f.input :name
            f.input :description, as: :string
            f.input :slug
            f.input :video
            f.input :category_id, as: :select, collection: Category.all
            f.input :photo, as: :file, hint: image_tag(f.object.photo.url)
          end
        end

        tab 'Maths' do
          f.inputs 'Maths' do
            f.input :suggested_weed
            f.input :suggested_portion
          end
        end

        tab 'Ingredients & Instructions' do
          f.inputs 'Ingredients & Instructions' do
            f.label "Ingredients"
            f.cktext_area :ingredients, label: "Ingredients"

            f.label  "Instructions"
            f.cktext_area :instructions, label: "Instructions"
          end
        end
      end
      f.actions
    end
  end
end
