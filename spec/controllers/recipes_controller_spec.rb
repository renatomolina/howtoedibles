require 'rails_helper'

RSpec.describe RecipesController, type: :controller do
  let!(:category) { create(:category) }
  let!(:recipe) { create(:recipe) }

  shared_examples 'loads categories' do
    it 'loads and assigns all categories to @categories' do
      send_request
      expect(assigns(:categories)).to eq(Category.all)
    end
  end

  describe 'GET index' do
    def send_request
      get :index
    end

    include_examples 'loads categories'

    it 'loads and assigns all recipes to @recipes' do
      send_request
      expect(assigns(:recipes).map(&:id)).to eq(Recipe.all.map(&:id))
    end

    it 'assigns a default value to @suggested_weed' do
      send_request
      expect(assigns(:suggested_weed)).to eq(4)
    end

    it 'assigns a default value to @suggested_portion' do
      send_request
      expect(assigns(:suggested_portion)).to eq(50)
    end
  end

  describe 'GET show' do
    let(:recipe) { create(:recipe, category: category, suggested_weed: 4, suggested_portion: 50) }

    def send_request
      get :show, params: { category_id: recipe.category.slug, id: recipe.slug }
    end

    include_examples 'loads categories'

    it 'loads and assigns a given recipe to @recipe' do
      send_request
      expect(assigns(:recipe)).to eq(recipe)
    end

    it 'assigns a default value to @suggested_weed' do
      send_request
      expect(assigns(:suggested_weed)).to eq(recipe.suggested_weed)
    end

    it 'assigns a default value to @suggested_portion' do
      send_request
      expect(assigns(:suggested_portion)).to eq(recipe.suggested_portion)
    end
  end
end
