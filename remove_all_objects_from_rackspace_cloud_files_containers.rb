#!/usr/bin/env ruby
# Author: Jason Barnett <J@sonBarnett.com>

require 'fog'

service = Fog::Storage.new({
    :provider            => 'Rackspace',               # Rackspace Fog provider
    :rackspace_username  => 'your_rackspace_username', # Your Rackspace Username
    :rackspace_api_key   => 'your_api_key',            # Your Rackspace API key
    :rackspace_region    => :ord,                      # Defaults to :dfw
    :connection_options  => {},                        # Optional
    :rackspace_servicenet => true                      # Optional
})

containers = service.directories.select do |s|
  s.count > 0                    # Find all containers that aren't empty
  s.key =~ /cloudfiles_backups/
end

containers.each do |container|
  total   = container.count
  current = container.count
  puts
  puts "-----------------------------------------"
  puts "-- Removing _ALL_ objects from #{container.key}"
  puts "-----------------------------------------"
  puts
  container.files.each do |file|
    ## I had to implement a retry because Rackspace Cloud Files continued to give random 404 errors, this fixed it.
    tries ||= 5
    puts "(#{current} of #{total}) Removing #{file.key}"
    begin
      file.destroy
    rescue NotFound => e
      retry unless (tries -= 1).zero?
    else
      current -= 1
    end
  end
end
