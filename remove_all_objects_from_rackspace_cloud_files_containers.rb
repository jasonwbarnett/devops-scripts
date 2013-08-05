#!/usr/bin/env ruby
# Author: Jason Barnett <J@sonBarnett.com>

begin
  require 'fog'
rescue LoadError
  puts "You need the fog gem..."
  puts "$ gem install fog"
  exit 1
end
require 'optparse'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.on("-u", "--username",
    "Rackspace Username"
  ) { |value| options[:username] = value }

  opts.on("--api-key",
    "Rackspace API Key"
  ) { |value| options[:api_key] = value }

  opts.on("--delete-empty",
    "Deletes all empty containers, regardless of name."
  ) { |value| options[:delete_empty] = true }

  opts.on("--dir-regexp REGEXP",
    "Deletes all files from containers that match regexp."
  ) { |value| options[:dir_regexp] = value }

  opts.on("-f", "--force",
    "Omits all prompts and just moves forward without asking anything. Only use if you're sure!"
  ) { |value| options[:force] = true }

  opts.on("--debug",
    "Enables some helpful debugging output."
  ) { |value| options[:debug] = true }

  opts.on("-h", "--help", "Display this help message.") do
    puts opts
    exit 2
  end
end


begin
  optparse.parse!
rescue OptionParser::MissingArgument
  puts "You're missing an argument...\n\n"
  puts optparse
  exit
end


p options if options[:debug] == true
p ARGV    if options[:debug] == true


service = Fog::Storage.new({
    :provider            => 'Rackspace',               # Rackspace Fog provider
    :rackspace_username  => 'your_rackspace_username', # Your Rackspace Username
    :rackspace_api_key   => 'your_api_key',            # Your Rackspace API key
    :rackspace_region    => :ord,                      # Defaults to :dfw
    :connection_options  => {},                        # Optional
    :rackspace_servicenet => true                      # Optional, only use if you're the Rackspace Region Data Center
})

containers = service.directories.select do |s|
  s.count > 0 and s.key =~ /cloudfiles_backups/  # Select all containers that aren't empty and their name matches the regex
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
