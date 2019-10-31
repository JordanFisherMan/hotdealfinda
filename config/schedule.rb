# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
# set :rbenv_root, '/opt/rbenv'
# set :rbenv_version, '2.3.3'
# set :environment, "production"

set :output,   standard: "log/#{@environment}_cron.log",
               error: "log/#{@environment}_cron_error.log"

job_type :thor, 'cd :path && :environment_variable=:environment :rbenv_root :rbenv_version do bundle exec thor :task :output'

every 6.hours do
  thor 'import:fetch'
end

every 1.days, at: '12:00 am' do
  thor 'import:remove_expired_deals'
end
