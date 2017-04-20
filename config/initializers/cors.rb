if defined? Rack::Cors
  Rails.configuration.middleware.insert_before 0, Rack::Cors do
    allow do
      origins %w[
         http://howtoedibles.com
         http://www.howtoedibles.com
         http://howtoedibles.herokuapp.com
      ]
      resource '/assets/*'
    end
  end
end
