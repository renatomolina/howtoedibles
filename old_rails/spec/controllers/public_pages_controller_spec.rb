require 'rails_helper'

RSpec.describe PublicPagesController, type: :controller do
  describe 'GET show' do
    context 'public_page is known' do
      it 'sets @template_name' do
        get :show, params: { public_page: 'hiring' }
        expect(assigns[:template_name]).to eq('hiring')
      end
  
      it 'renders show template' do
        get :show, params: { public_page: 'hiring' }
        expect(response).to render_template(:hiring)
      end
    end

    context 'public_page is NOT known' do
      it 'does NOT renders show template' do
        expect{ get :show, params: { public_page: 'unknown' } }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
