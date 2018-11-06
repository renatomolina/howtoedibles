require 'colorize'
require 'digest'

folder_name = ENV['BRANCH_NAME'] + ENV['SEMAPHORE_BUILD_NUMBER']

cmd = <<~CMD
  DISABLE_SPRING=1 bundle exec rake spec SPEC_OPTS="--format doc --color"
CMD

success = system(cmd)

exit success ? 0 : 1
