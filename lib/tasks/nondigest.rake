# Non-digest assets so Nginx can reference our 404 and 500.html pages.
require 'fileutils'

desc "Create nondigest versions of all digest assets"
task "assets:precompile" do
  fingerprint = /\-[0-9a-f]{32}\./
  # Remove all non-fingerprinted assets.
  Dir["public/assets/**/*"].each do |file|
    next if file ~ fingerprint
    next if File.directory?(file)
    next if file.split(File::Separator).last =~ /^manifest/
    FileUtils.rm file, nondigest, verbose: true
  end
  # Recreate non-fingerprinted assets.
  Dir["public/assets/**/*"].each do |file|
    next if file !~ fingerprint
    next if File.directory?(file)
    next if file.split(File::Separator).last =~ /^manifest/
    nondigest = file.sub fingerprint, '.'
    FileUtils.cp file, nondigest, verbose: true
  end
end
