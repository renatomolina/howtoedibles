Aws.config.update({
	  region: 'us-east-1',
	  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
		cache_control: 'max-age=86400, private'
})

Aws::VERSION =  Gem.loaded_specs["aws-sdk"].version