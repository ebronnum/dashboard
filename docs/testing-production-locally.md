# Testing Production Locally

Especially with asset additions and changes, it can be a good idea to test your local build in production mode. 

## Steps

1. `RAILS_ENV=production bundle exec rake db:create`
1. `RAILS_ENV=production bundle exec rake db:migrate`
1. `RAILS_ENV=production bundle exec rake seed:all`
1. `RAILS_ENV=production bundle exec rake assets:precompile`
1. `RAILS_ENV=production rails s`
