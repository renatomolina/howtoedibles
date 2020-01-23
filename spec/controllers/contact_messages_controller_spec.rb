require 'rails_helper'

RSpec.describe ContactMessagesController, type: :controller do

  describe 'GET new' do

    it 'assigns @contact_message' do
      get :new
      expect(assigns[:contact_message]).to be_kind_of(ContactMessage)
    end
  end

  describe 'POST create' do
    let(:contact_message_params) { { contact_message: {name: 'Babulino', email: 'babulino@gmail.com', body: 'woof'} } }

    def send_request
      post :create, params: contact_message_params
    end

    it 'assigns @contact_message' do
      send_request
      expect(assigns[:contact_message].name).to eq('Babulino')
      expect(assigns[:contact_message].email).to eq('babulino@gmail.com')
      expect(assigns[:contact_message].body).to eq('woof')
    end

    context 'params are valid' do
      let(:contact_message_params) { { contact_message: {name: 'Babulino', email: 'babulino@gmail.com', body: 'woof'} } }

      it 'redirects to contact page' do
        send_request
        expect(response).to redirect_to(new_contact_message_url)
      end

      it 'shows success message' do
        send_request
        expect(flash[:notice]).to eq('Message received')
      end

      it 'calls message mailer' do
        expect(ContactMessageMailer).to receive_message_chain(:contact, :deliver_now)
        send_request
      end
    end

    context 'params are NOT valid' do
      let(:contact_message_params) { { contact_message: {name: '', email: '', body: ''} } }

      it 'render new' do
        send_request
        expect(response).to render_template(:new)
      end
    end
  end
end
