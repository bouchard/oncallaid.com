require 'time'

env :PATH, '/usr/local/bin:/usr/bin:/bin'

job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
job_type :script_without_bundler, "cd :path && RAILS_ENV=:environment :task :output"
job_type :runner, "cd :path && RAILS_ENV=:environment bundle exec rails runner :task :output"

# Backup the database and send to Amazon S3.
every 1.day, :at => Time.parse('08:05').utc do
  script_without_bundler "backup perform -t oca --config_file config/backup.rb"
end