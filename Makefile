rspec:
	RAILS_ENV=test bin/rails db:environment:set
	RAILS_ENV=test bundle exec rspec spec