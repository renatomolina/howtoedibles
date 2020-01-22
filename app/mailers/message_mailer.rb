class MessageMailer < ApplicationMailer
  def contact(message)
    @name = message.name
    @email = message.email
    @body = message.body
    mail to: 'howtoedibles@gmail.com', from: @email, subject: 'Contact'
  end
end
