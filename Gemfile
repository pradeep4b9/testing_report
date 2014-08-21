source 'https://rubygems.org'

ruby '2.1.2'
gem 'rails', '4.1.5'
gem 'therubyracer', :platform=>:ruby

#Database
gem 'mongoid'
gem 'bson_ext'
gem 'mongoid_slug'

# Database encryption
gem 'symmetric-encryption', '~> 3.4.0'

#User Auth
gem 'devise'
gem "devise-async", "~> 0.7.0"

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'figaro', '>= 1.0.0.rc1'
gem 'haml-rails'
gem 'simple_form'




group :development do
  # gem 'capistrano', '~> 3.1.0'
  # gem 'capistrano-bundler'
  # gem 'capistrano-rails', '~> 1.1.0'
  # gem 'capistrano-rails-console'
  # gem 'capistrano-rvm', '~> 0.1.1'

  gem 'capistrano', '~> 3.1.0'
  # cap tasks to manage puma application server
  gem 'capistrano-puma', require: false
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm',   '~> 0.1', require: false

  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'thin'
  gem 'spring'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver'
end

group :production do
  # gem 'unicorn'
  # gem 'unicorn-rails'
  gem 'puma'
end
