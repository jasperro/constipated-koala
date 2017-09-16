# encoding: UTF-8
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails'
gem 'mysql2'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'sass-rails'
gem 'coffee-rails'

# authentication gems
gem 'devise', :github => 'plataformatec/devise'
gem 'doorkeeper'

# logging, using master for rails 5 support
gem 'impressionist', :github => 'charlotte-ruby/impressionist'

# rests calls for mailgun
gem 'rest-client'

# search engine
gem 'fuzzily', :github => 'svsticky/fuzzily'
gem 'responders'

# settings cached in rails environment
gem 'rails-settings-cached'

# Paperclip easy file upload to S3
gem 'paperclip'

group :production do
  gem 'unicorn'
  gem 'aws-sdk', '>= 2.0'
  gem 'uglifier'
end

group :staging do
  gem 'unicorn'
  gem 'aws-sdk', '>= 2.0'
  gem 'uglifier'

  gem 'faker', '>= 1.8.4'
end

group :development do
  gem 'puma'
  gem 'listen'

  gem 'web-console'
  gem 'byebug', platform: :mri

  gem 'faker', '>= 1.8.4'
  gem 'spring'
end

group :test do
  gem 'spring'
  gem 'faker', '>= 1.8.4'
end
