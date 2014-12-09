source 'http://rubygems.org'
ruby '2.1.4'

gem 'rails', '4.0.0'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', :platforms => :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'

gem 'haml'

# Config variables
gem 'dotenv-rails', :groups => [:development, :test]

# DB
group :development, :test do
  gem 'sqlite3'
  gem 'faker'
end

group :production do
  gem 'pg'
end

# App Server
gem 'unicorn'

# Connecting to web
gem 'oauth'
gem 'devise', "~> 3.2.2"
gem 'rails_12factor', :group => :production
