# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

# Rails
gem 'rails', '~> 7.1.3'
# gem "tailwindcss-rails", "~> 2.6"
gem 'bootsnap', require: false
gem 'importmap-rails'
gem 'jbuilder'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

# Infrastructure
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'redis', '>= 4.0.1'
gem 'sidekiq', '~> 7.2'

# Serialization
gem 'jsonapi.rb', '~> 2.0'
gem 'jsonapi-serializer', '~> 2.2'

# Cloud SDKs
gem 'aws-sdk-s3', '~> 1'

# Authentication / Authorization
gem 'action_policy'
gem 'devise', '~> 4.9'
gem 'doorkeeper-openid_connect', '~> 1.8'
gem 'jwt', '~> 2.8'

# VCS Systems
gem 'git', '~> 1.19'
gem 'octokit'

gem 'acts-as-taggable-on', '~> 10.0'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'json_matchers'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
end

gem 'config'
gem 'cssbundling-rails', '~> 1.4'
gem 'doorkeeper', '~> 5.7'
gem 'httpparty', '~> 0.2.0'
gem 'ruby-terraform', '~> 1.8'
gem 'rubyzip', require: 'zip'
gem 'seedbank', '~> 0.5.0'

gem 'jsbundling-rails', '~> 1.3'

gem 'carrierwave', '~> 3.0'
gem 'scout_apm', '~> 5.4'
gem 'vault-rails', require: false

gem 'fog-aws', '~> 3.27'

gem 'fog-core', '~> 2.4'

gem 'rubocop', '~> 1.66'

gem 'rubocop-rails', require: false
gem 'rubocop-rspec', require: false
gem 'rubocop-rspec_rails', require: false

gem 'fabrication'
gem 'faker', '~> 3.4'
