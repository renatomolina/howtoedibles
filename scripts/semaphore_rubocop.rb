cmd = <<~CMD
  bundle exec ruby ./bin/rubocop \
    --display-cop-names \
    --display-style-guide \
    --format progress
CMD

system(cmd)
