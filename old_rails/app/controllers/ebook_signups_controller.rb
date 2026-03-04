class EbookSignupsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @ebook_signup = EbookSignup.new
    render layout: 'landing_page'
  end

  def create
    ebook_signup = EbookSignup.new(ebook_signup_params)

    if ebook_signup.save
      flash[:success] = 'Thanks for signing up! You are on our waiting list, we will get in touch soon.'
    else
      flash[:danger] = ebook_signup.errors.full_messages.first
    end

    redirect_to ebook_signups_path
  end

  private

  def ebook_signup_params
    params.require(:ebook_signup).permit(:email, :email)
  end
end
