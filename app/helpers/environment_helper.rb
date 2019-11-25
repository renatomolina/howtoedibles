module EnvironmentHelper
  def howtoedibles?
    ENV['APP_ENV'] == 'howtoedibles'
  end

  def laricando?
    ENV['APP_ENV'] == 'laricando'
  end
end