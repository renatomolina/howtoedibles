# "Repo" in this context does not refer to a Git repo.
# It refers to a repo of config variables for the Feature gem.
repo = Feature::Repository::YamlRepository.new("#{Rails.root}/config/feature.yml", Rails.env)
Feature.set_repository repo
