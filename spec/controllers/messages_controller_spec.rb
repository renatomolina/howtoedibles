require 'rails_helper'

RSpec.describe MessagesController, type: :controller do

  describe 'GET new' do

    it 'assigns @message' do
      get :new
      expect(assigns[:message]).to be_kind_of(Message)
    end
  end

  describe 'POST create' do
    let(:message_params) { { message: {name: 'Babulino', email: 'babulino@gmail.com', body: 'woof'} } }

    def send_request
      post :create, params: message_params
    end

    it 'assigns @message' do
      send_request
      expect(assigns[:message].name).to eq('Babulino')
      expect(assigns[:message].email).to eq('babulino@gmail.com')
      expect(assigns[:message].body).to eq('woof')
    end

    context 'params are valid' do
      let(:message_params) { { message: {name: 'Babulino', email: 'babulino@gmail.com', body: 'woof'} } }

      it 'redirects to contact page' do
        send_request
        expect(response).to redirect_to(new_message_url)
      end

      it 'shows success message' do
        send_request
        expect(flash[:notice]).to eq('Message received')
      end

      it 'calls message mailer' do
        expect(MessageMailer).to receive_message_chain(:contact, :deliver_now)
        send_request
      end
    end

    context 'params are NOT valid' do
      let(:message_params) { { message: {name: '', email: '', body: ''} } }

      it 'render new' do
        send_request
        expect(response).to render_template(:new)
      end
    end
  end
end
