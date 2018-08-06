class HomeController < ApplicationController
  def robots
    robots = File.read(Rails.root.join('public', "robots.#{ENV['ENV_NAME']}.txt"))
    render plain: robots
  end
end