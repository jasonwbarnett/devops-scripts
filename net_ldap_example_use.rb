#!/usr/bin/env ruby
require 'net/ldap'

# Author: Jason Barnett <J@sonBarnett.com>
# This is an example on how to use Net::LDAP module.

## Main ##
##########
ldap = Net::LDAP.new :host => 'dc1.domain.internal',
  :port       => 636,
  :encryption => :simple_tls,
  :auth => {
    :method => :simple,
    :username => 'user@domain.internal',
    :password => 'secretpassword'
  }

filter = Net::LDAP::Filter.eq("objectClass", "person") &
  Net::LDAP::Filter.eq("objectClass", "user") &
  Net::LDAP::Filter.present("mail") &
  Net::LDAP::Filter.construct('(!(userAccountControl:1.2.840.113556.1.4.803:=2))')

treebase = "OU=Users,DC=domain,DC=internal"

search_results = ldap.search(:base => treebase, :filter => filter)

search_results.each do |entry|
  cn      = entry.attribute_names.include?(:cn)             ? entry.cn.first       : nil
  mail    = entry.attribute_names.include?(:mail)           ? entry.mail.first     : nil
  aliases = entry.attribute_names.include?(:proxyaddresses) ? entry.proxyaddresses : nil

  if aliases
    aliases.map!{|x| x.downcase }
    domain_aliases = aliases.delete_if { |x| x =~ /^x(4|5)00:/i }.map { |x| x.sub(/^[^:]*:/, '') }.delete_if { |x| x.downcase == entry.mail.first.downcase }

    domain_aliases.map! {|x| x.split('@').first.downcase.strip }
    domain_aliases << mail.split('@').first.downcase.strip
    domain_aliases.uniq!
    domain_aliases.map! {|x| x + '@domain.com' }

    final = domain_aliases - aliases

    unless final.empty?
      ldap.add_attribute entry.dn, :proxyaddresses, final
      puts "#{cn}|#{final.join(',')}|#{ldap.get_operation_result.code}|#{ldap.get_operation_result.message}"
    end
  end
end
