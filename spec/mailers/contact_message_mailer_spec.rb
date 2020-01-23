require 'rails_helper'

RSpec.describe ContactMessageMailer, type: :mailer do
  describe 'contact' do
    let(:name) {'Babulino'}
    let(:contact_message) { build(:contact_message, name: name) }
    let(:mail) { ContactMessageMailer.contact(contact_message) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Contact')
      expect(mail.to).to eq(['howtoedibles@gmail.com'])
      expect(mail.from).to eq([contact_message.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(contact_message.body)
    end
  end
end
