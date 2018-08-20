source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'thor'
gem 'activesupport'

group :debug do
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-nav'
  gem 'pry-remote'
end
