#!/usr/bin/env ruby
# Author: Jason Barnett <J@sonBarnett.com>

require 'fog'

service = Fog::Storage.new({
    :provider            => 'Rackspace',               # Rackspace Fog provider
    :rackspace_username  => 'your_rackspace_username', # Your Rackspace Username
    :rackspace_api_key   => 'your_api_key',            # Your Rackspace API key
    :rackspace_region    => :ord,                      # Defaults to :dfw
    :connection_options  => {},                        # Optional
    :rackspace_servicenet => true                      # Optional, only use if you're the Rackspace Region Data Center
})

containers = service.directories.select do |s|
  s.count > 0                    # Select all containers that aren't empty
  s.key =~ /cloudfiles_backups/  # Select all containers that match a certain name
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
    ## I had to implement a retry because Rackspace Cloud Files kept giving me random errors, this is a work around.
    max_retries ||= 5
    try = 0
    puts "(#{current} of #{total}) Removing #{file.key}"
    begin
      file.destroy
    rescue Excon::Errors::NotFound, Excon::Errors::Timeout, Fog::Storage::Rackspace::NotFound => e
      if try == max_retries
        puts "Unable to remove file..."
      else
        try += 1
        puts "Retry \##{try}"
        retry
      end
    else
      current -= 1
    end
  end
end
