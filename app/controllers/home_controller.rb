class HomeController < ApplicationController
  def robots
    robots = File.read(Rails.root.join('config', "robots.#{ENV['APP_ENV']}.txt"))
    render plain: robots
  end
end