%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
).each { |path| Spring.watch(path) }

Spring.after_fork do
  if defined?(ActiveRecord::Base)
    if Octopus.enabled?
      Octopus.config[Rails.env.to_s]['master'] = ActiveRecord::Base.connection.config
      ActiveRecord::Base.connection.initialize_shards(Octopus.config)
    end

    ActiveRecord::Base.establish_connection
    QC.default_conn_adapter = QC::ConnAdapter.new(ActiveRecord::Base.connection.raw_connection)
  end
end
