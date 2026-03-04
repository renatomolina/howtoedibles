namespace :static do
  desc "Export recipes and categories to static-site/data/recipes.json"
  task export_recipes: :environment do
    output_path = Rails.root.join("static-site", "data", "recipes.json")
    FileUtils.mkdir_p(File.dirname(output_path))

    categories = Category.joins(:recipes).where(recipes: { published: true })
                         .order("categories.id")
                         .includes(recipes: :category)
                         .distinct

    categories_data = categories.map do |category|
      published_recipes = category.recipes.where(published: true).order(:position)
      {
        id: category.id,
        name: category.name,
        slug: category.slug,
        recipes: published_recipes.map { |r| { id: r.id, slug: r.slug, name: r.name } }
      }
    end

    recipes_data = Recipe.published.order(:position).includes(:category).map do |r|
      {
        id: r.id,
        name: r.name,
        slug: r.slug,
        description: r.description,
        ingredients: r.ingredients,
        instructions: r.instructions,
        suggested_quantity: r.suggested_quantity || Recipe::DEFAULT_QUANTITY,
        suggested_portion: r.suggested_portion || Recipe::DEFAULT_PORTION,
        video: r.video.presence,
        photo_file_name: r.photo_file_name,
        category_name: r.category.name,
        category_slug: r.category.slug,
        position: r.position
      }
    end

    result = { categories: categories_data, recipes: recipes_data }
    File.write(output_path, JSON.pretty_generate(result))

    puts "Exported #{recipes_data.count} recipes across #{categories_data.count} categories"
    puts "Written to: #{output_path}"
  end
end
