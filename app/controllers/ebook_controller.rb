class EbookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render layout: 'landing_page'
  end

  def signup
    list_signup = ListSignup.new(email: params[:email])

    if list_signup.valid?
      flash[:success] = 'Thanks for signing up! You are on our waiting list, we will get in touch soon.'
    else
      flash[:danger] = list_signup.errors.full_messages.first
    end
    
    redirect_to ebook_path
  end
end