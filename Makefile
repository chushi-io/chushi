rspec:
	RAILS_ENV=test bin/rails db:reset
	RAILS_ENV=test bin/rails db:prepare
	RAILS_ENV=test bin/rails db:environment:set
	RAILS_ENV=test bundle exec rspec

rubocop:
	bundle exec rubocop

.PHONY: ui

ui:
	cd ui && npm run build && cp -r ./build/* ../public/