class PublicPagesController < ApplicationController
  def calculator
  end

  def ebook
    render layout: "landing_page"
  end
end
