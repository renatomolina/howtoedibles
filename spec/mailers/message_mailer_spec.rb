require 'rails_helper'

RSpec.describe MessageMailer, type: :mailer do
  describe 'contact' do
    let(:name) {'Babulino'}
    let(:message) { build(:message, name: name) }
    let(:mail) { MessageMailer.contact(message) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Contact')
      expect(mail.to).to eq(['howtoedibles@gmail.com'])
      expect(mail.from).to eq([message.email])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(message.body)
    end
  end
end
