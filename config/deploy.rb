# config valid only for current version of Capistrano
lock '3.11.0'

set :stages, %w(production staging)
set :default_stage, "staging"
set :rails_env, "production"
set :user, 'deploy'
set :deploy_to, '/home/deploy/hotdealsfinda'

set :application, "hotdealsfinda"
set :repo_url, "git@github.com:JordanFisherMan/hotdealsfinda.git"
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.6.3'
set :rbenv_path, '/home/deploy/.rbenv/bin/rbenv'

# in case you want to set ruby version from the file:
# set :rbenv_ruby, File.read('.ruby-version').strip

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value
set :pty, true

set :linked_files, %w{config/database.yml config/master.key}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads public/images}
Rake::Task["deploy:set_linked_dirs"].clear_actions

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :bundle_binstubs, nil

set :keep_releases, 2
# set :rvm_type, :user
# set :rvm_ruby_version, 'ruby-2.3.1' # Edit this if you are using MRI Ruby
# set :rvm_map_bins, fetch(:rvm_map_bins, []).push('thor')
set :bundle_bins, fetch(:bundle_bins, []).push('thor')
set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock" # accept array for multi-bind
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 8]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false
set :puma_user, fetch(:user)

# tailing logs
set :logtail_files, %w(/var/log/syslog)
set :logtail_lines, 50

set :logrotate_template_path, "#{stage_config_path}/templates/logrotate.erb"

# set :nginx_template, "#{stage_config_path}/templates/nginx.conf.erb"
set :nginx_template, :default
# set :nginx_service_path, "/etc/init.d/nginx"
set :nginx_roles, :web
set :nginx_static_dir, "public"
set :nginx_application_name, "#{fetch :application}-#{fetch :stage}"
set :nginx_use_ssl, true
set :nginx_ssl_certificate, 'fullchain.pem'
set :nginx_ssl_certificate_key, 'privkey.pem'
set :nginx_read_timeout, 30
set :app_server, true
set :app_server_socket, "#{shared_path}/tmp/sockets/puma.sock"
set :app_server_host, "127.0.0.1"

set :whenever_variables, -> {
  "\'environment=#{fetch :whenever_environment}" \
  "&rbenv_version=#{fetch :rbenv_ruby}" \
  "&rbenv_path=#{fetch :rbenv_path}\'"
}
