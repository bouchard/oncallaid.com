# Server-wide (and application-specific) variables are set in
# /etc/environment and the easiest way to load them into Rails is here.

if File.exists?('/etc/environment')
  File.read('/etc/environment').split(/\n/).map{ |l| l.strip.split(/\=/) }.each do |l|
    ENV[l[0]] = (l[1] || '').gsub('"','') unless l[0].nil? || l[0].length == 0
  end
end