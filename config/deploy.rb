lock '3.3.5'

set :application, "oncallaid.com"
set :repo_url, "git@github.com:bouchard/#{fetch(:application)}.git"

set :ssh_options, {
  :forward_agent => true,
  :user => ENV['USER']
}

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/var/rails/#{fetch(:application)}"

set :whenever_environment,  -> { fetch(:rails_env) }
set :whenever_identifier,   -> { "#{fetch(:application)}_#{fetch(:rails_env)}" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
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

  after   :publishing, :restart
  # before  :started,    'delayed_job:stop'
  # after   :finished,   'delayed_job:start'

end

namespace :db do

  desc "Copy the remote production database to the local development database."
  task :reload_locally do

    db = YAML::load_file('config/database.yml')['production']
    file = "/tmp/#{fetch(:application)}.dump.#{Time.now.to_i}.sql.bz2"

    on roles(:db), :primary => true do
      execute "pg_dump --clean --no-owner --no-privileges -U#{db['username']} #{db['database']} | bzip2 > #{file}"
      download! file, file
      ddb = YAML::load_file('config/database.yml')['development']
      ENV['PGPASSWORD'] = ddb['password']
      run_locally do
        execute "bzip2 -cd #{file} | psql -U #{ddb['username']} -d #{ddb['database']}"
      end
      execute "rm #{file}"
      puts "Finished reloading locally."
    end
  end
end


namespace :rails do
  desc "Open the Rails console on the remote server."
  task :console do
    on roles(:app), :primary => true do
      rails_env = fetch(:rails_env) || fetch(:stage)
      execute_interactively "ruby #{current_path}/bin/rails console #{rails_env}"
    end
  end

  desc "Open the Rails database console on the remote server."
  task :dbconsole do
    on roles(:db), :primary => true do
      rails_env = fetch(:rails_env) || fetch(:stage)
      execute_interactively "ruby #{current_path}/bin/rails dbconsole #{rails_env}"
    end
  end

  def execute_interactively(command)
    exec "ssh #{host.hostname} -t 'cd #{current_path} && #{command}'"
  end
end