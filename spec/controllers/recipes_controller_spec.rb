require 'rails_helper'

RSpec.describe RecipesController, type: :controller do
  let!(:category) { create(:category) }
  let!(:recipe) { create(:recipe) }

  shared_examples 'loads categories' do
    it 'loads and assigns all categories to @categories' do
      send_request
      expect(assigns(:category_list)).to eq(Category.all)
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

    it 'assigns a default value to @suggested_quantity' do
      send_request
      expect(assigns(:suggested_quantity)).to eq(3.5)
    end

    it 'assigns a default value to @suggested_portion' do
      send_request
      expect(assigns(:suggested_portion)).to eq(50)
    end

    it 'assigns a default value to @suggested_potency' do
      send_request
      expect(assigns(:suggested_potency)).to eq(14)
    end
  end

  describe 'GET show' do
    let(:recipe) { create(:recipe, category: category, suggested_quantity: 4, suggested_portion: 50) }
    let(:params) { { recipe_slug: recipe.slug } }
    def send_request
      get :show, params: params
    end

    include_examples 'loads categories'

    it 'loads and assigns a given recipe to @recipe' do
      send_request
      expect(assigns(:recipe)).to eq(recipe)
    end

    context 'params are nil' do
      it 'assigns a default value to @suggested_quantity' do
        send_request
        expect(assigns(:suggested_quantity)).to eq(recipe.suggested_quantity)
      end

      it 'assigns a default value to @suggested_portion' do
        send_request
        expect(assigns(:suggested_portion)).to eq(recipe.suggested_portion)
      end

      it 'assigns a default value to @suggested_potency' do
        send_request
        expect(assigns(:suggested_potency)).to eq(14)
      end
    end

    context 'quantity param is setted' do
      let(:params) { { recipe_slug: recipe.slug, quantity: 1 } }

      it 'assigns the param value to @suggested_quantity' do
        send_request
        expect(assigns(:suggested_quantity)).to eq('1')
      end
    end

    context 'portion param is setted' do
      let(:params) { { recipe_slug: recipe.slug, portion: 1 } }

      it 'assigns the param value to @suggested_portion' do
        send_request
        expect(assigns(:suggested_portion)).to eq('1')
      end
    end

    context 'potency param is setted' do
      let(:params) { { recipe_slug: recipe.slug, potency: 1 } }

      it 'assigns the param value to @suggested_potency' do
        send_request
        expect(assigns(:suggested_potency)).to eq('1')
      end
    end
  end
end
