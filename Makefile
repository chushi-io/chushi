rspec:
	RAILS_ENV=test bin/rails db:reset
	RAILS_ENV=test bin/rails db:prepare
	RAILS_ENV=test bin/rails db:environment:set
	RAILS_ENV=test bundle exec rspec spec/requests/api/v2/storage_controller_spec.rb

rubocop:
	bundle exec rubocop