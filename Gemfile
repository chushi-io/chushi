source "https://rubygems.org"

ruby "3.2.2"

# Rails
gem "rails", "~> 7.1.3"
gem "tailwindcss-rails", "~> 2.6"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# Infrastructure
gem "pg", "~> 1.1"
gem "redis", ">= 4.0.1"
gem "sidekiq", "~> 7.2"
gem "puma", ">= 5.0"

# Serialization
gem "jsonapi-serializer", "~> 2.2"
gem "jsonapi.rb", "~> 2.0"

# Cloud SDKs
gem 'aws-sdk-s3', '~> 1'

# Authentication / Authorization
gem "jwt", "~> 2.8"
gem "devise", "~> 4.9"
gem 'action_policy'
gem "doorkeeper-openid_connect", "~> 1.8"

# VCS Systems
gem "git", "~> 1.19"
gem 'octokit'

gem 'acts-as-taggable-on', '~> 10.0'

group :development, :test do
  gem "dotenv"
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end


gem "doorkeeper", "~> 5.7"

gem "bunny", "~> 2.23"

gem "sneakers", "~> 2.11"
