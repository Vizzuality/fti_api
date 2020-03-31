# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.6'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Active admin
gem 'active_admin_paranoia'
gem 'active_admin_sidebar', git: 'https://github.com/activeadmin-plugins/active_admin_sidebar.git'
gem 'activeadmin'
gem 'activeadmin-globalize', '~> 1.0.0.pre', github: 'fabn/activeadmin-globalize', branch: 'develop'
gem 'activeadmin_addons', '1.5'

gem 'sass-rails'
gem 'sassc-rails'

# Active Admin skins
gem 'active_skin'

# WYSIWYG
gem 'activeadmin_quill_editor'

gem 'devise'

# Soft Delete
gem 'paranoia', "~> 2.2"

# Rails and DB
gem 'activerecord-postgis-adapter'
gem 'pg',    '~> 0.18'
gem 'rails', '~> 5.0.2'

# API
gem 'jsonapi-resources', '0.9.0'
gem 'oj'
gem 'oj_mimic_json'

# API Documentation
gem 'rspec_api_documentation'
gem 'rswag-api'
gem 'rswag-ui'


# Data
gem 'activerecord-import'
# gem 'globalize', '5.1.0'
gem 'seed-fu'

# Validation
gem 'valid_url'

# Auth and Omniauth
gem 'bcrypt'
gem 'cancancan'
gem 'jwt'

# Uploads
gem 'carrierwave-base64'
gem 'mini_magick'

# Templating
gem 'slim-rails'

# Performance
gem 'newrelic_rpm'
gem 'oink'

# Monitoring
gem 'appsignal'

# Mail
gem 'sendgrid-ruby'

# file utilites
gem 'rubyzip'

group :development, :test do
  gem 'byebug',                    platform: :mri
  gem 'faker'
  gem 'rails-erd'
  gem 'rubocop',                   require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'webmock'
end

group :development do
  gem 'annotate'
  gem 'brakeman',                  require: false
  gem 'capistrano',                '~> 3.6'
  gem 'capistrano-bundler'
  gem 'capistrano-env-config'
  gem 'capistrano-passenger'
  gem 'capistrano-rails',          '~> 1.2'
  gem 'capistrano-resque',         require: false
  gem 'capistrano-rvm'
  gem 'listen',                    '~> 3.0.5'
  gem 'pry-rails'
  gem 'spring'
  gem 'spring-watcher-listen',     '~> 2.0.0'
end

group :test do
  gem 'bullet'
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_bot_rails'
  gem 'rspec-activejob'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 4.0.1'
  gem 'simplecov'
  gem 'timecop'
end

# Server
gem 'dotenv-rails'
gem 'puma'
gem 'rack-cors'
gem 'redis-rails'
gem 'resque'
gem 'resque-scheduler'
gem 'resque_mailer'
gem 'tzinfo-data'
