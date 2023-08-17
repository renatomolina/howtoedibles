class ContactMessagesController < ApplicationController
  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)

    if verify_recaptcha(model: @contact_message) && @contact_message.valid?
      ContactMessageMailer.contact(@contact_message).deliver_now
      flash[:notice] = t('.success')
      redirect_to new_contact_message_url
    else
      render :new
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :body)
  end
end
