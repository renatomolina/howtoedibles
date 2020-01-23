class ContactMessageMailer < ApplicationMailer
  def contact(contact_message)
    @name = contact_message.name
    @email = contact_message.email
    @body = contact_message.body
    mail to: 'howtoedibles@gmail.com', from: @email, subject: 'Contact'
  end
end
