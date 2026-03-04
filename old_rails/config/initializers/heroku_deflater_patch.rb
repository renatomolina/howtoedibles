module HerokuDeflater
  class CacheControlManager
    def cache_control_headers
      if rails_version_5?
        app.config.public_file_server.headers
      else
        app.config.static_cache_control
      end
    end
  end
end