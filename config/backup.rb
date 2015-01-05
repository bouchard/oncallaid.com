# encoding: utf-8

# Backup v4.x Configuration

##
# Backup
# Generated Main Config Template
#
# For more information:
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues

##
# Utilities
#
# If you need to use a utility other than the one Backup detects,
# or a utility can not be found in your $PATH.
#
#   Backup::Utilities.configure do
#     tar       '/usr/bin/gnutar'
#     redis_cli '/opt/redis/redis-cli'
#   end

##
# Logging
#
# Logging options may be set on the command line, but certain settings
# may only be configured here.
#
#   Backup::Logger.configure do
#     console.quiet     = true            # Same as command line: --quiet
#     logfile.max_bytes = 2_000_000       # Default: 500_000
#     syslog.enabled    = true            # Same as command line: --syslog
#     syslog.ident      = 'my_app_backup' # Default: 'backup'
#   end
#
# Command line options will override those set here.
# For example, the following would override the example settings above
# to disable syslog and enable console output.
#   backup perform --trigger my_backup --no-syslog --no-quiet

##
# Component Defaults
#
# Set default options to be applied to components in all models.
# Options set within a model will override those set here.
#
#   Backup::Storage::S3.defaults do |s3|
#     s3.access_key_id     = "my_access_key_id"
#     s3.secret_access_key = "my_secret_access_key"
#   end
#
#   Backup::Encryptor::OpenSSL.defaults do |encryption|
#     encryption.password = "my_password"
#     encryption.base64   = true
#     encryption.salt     = true
#   end

Backup::Model.new(:oca, 'Backup the OCA database.') do

  require 'yaml'

  db = YAML.load_file(File.expand_path('../config/database.yml', File.dirname(__FILE__)))

  database PostgreSQL do |d|
    d.name                = db['production']['database']
    d.username            = db['production']['username']
    d.password            = db['production']['password']
    d.host                = db['production']['host']
  end

  compress_with Bzip2

  time = Time.now
  if time.day == 1
    storage_id = :monthly
    keep = 6
  elsif time.sunday?
    storage_id = :weekly
    keep = 3
  else
    storage_id = :daily
    keep = 12
  end

  store_with S3, storage_id do |s|
    s.access_key_id       = ENV['S3_ACCESS_KEY_ID']
    s.secret_access_key   = ENV['S3_SECRET_ACCESS_KEY']
    s.bucket              = ENV['S3_BUCKET']
    s.fog_options         = { :path_style => true }
    s.region              = 'us-east-1'
    s.keep                = keep
  end

  # Disable mail gem requirement for now, not compatible with exception_notification.
  # notify_by Mail do |mail|
  #   mail.on_success = false
  #   mail.on_failure = true
  # end

end



# * * * * * * * * * * * * * * * * * * * *
#        Do Not Edit Below Here.
# All Configuration Should Be Made Above.

##
# Load all models from the models directory.
Dir[File.join(File.dirname(Config.config_file), "models", "*.rb")].each do |model|
  instance_eval(File.read(model))
end
