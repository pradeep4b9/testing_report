# Load DSL and Setup Up Stages
require 'capistrano/setup'
# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails/assets' # for asset handling add
# require 'capistrano/rails/migrations' # for running migrations

require 'capistrano/puma'
require 'capistrano/sidekiq'

# require 'capistrano/sidekiq/monit' #to require monit tasks # Only for capistrano3
# require 'capistrano/puma/workers' #if you want to control the workers (in cluster mode)
# require 'capistrano/puma/jungle'  #if you need the jungle tasks
# require 'capistrano/puma/nginx'   #if you want to upload a nginx site template

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails/tree/master/assets
#   https://github.com/capistrano/rails/tree/master/migrations
#

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
