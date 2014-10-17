set :application, 'mviproducts'
set :repo_url, 'git@bitbucket.org:mvi_admin/mviproducts.git'


set :deploy_to, '/home/ubuntu/mviproducts/demo'
set :scm, :git
# set :branch, 'master'
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :keep_releases, 5

set :format, :pretty
set :log_level, :debug
set :pty,  false
set :assets_roles, [:web, :app]
set :rails_env, 'production'


# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system }

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 16]
set :puma_workers, 0
set :puma_init_active_record, true
set :puma_preload_app, true

# set :sidekiq_config, -> { File.join(shared_path, 'config', 'sidekiq.yml') }
set  :sidekiq_default_hooks, true
set  :sidekiq_pid, -> {  File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid')}
set  :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
set  :sidekiq_log, -> {  File.join(shared_path, 'log', 'sidekiq.log')}
set  :sidekiq_options, -> {  nil}
set  :sidekiq_require, -> { nil}
set  :sidekiq_tag, -> { nil}
set  :sidekiq_config, -> { nil}
set  :sidekiq_queue, -> { nil}
set  :sidekiq_timeout, -> {  10}
set  :sidekiq_role, -> {  :app}
set  :sidekiq_processes, -> {  1}
set  :sidekiq_concurrency, -> { nil}
# :sidekiq_cmd, -> { "#{fetch(:bundle_cmd, "bundle")} exec sidekiq"  # Only for capistrano2.5
# :sidekiqctl_cmd, -> { "#{fetch(:bundle_cmd, "bundle")} exec sidekiqctl" # Only for capistrano2.5


namespace :deploy do

  # before :starting, :copy_puma

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :add_default_hooks do
    after 'deploy:starting', 'sidekiq:quiet'
    after 'deploy:updated', 'sidekiq:stop'
    after 'deploy:reverted', 'sidekiq:stop'
    after 'deploy:published', 'sidekiq:start'
  end

  after :finishing, 'deploy:cleanup'

end
