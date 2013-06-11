#!/usr/bin/env ruby
#
#  usn_example.rb
# 
require "./usn"

usn = USN.new(ARGV[0])

rels = usn.getUSNTargets()
print "Announce: #{usn.getDate()}\n"
print "Target: \n"
targets = usn.getUSNTargets
targets.each do |t|
  print " * #{t}\n"
end
print "URL: #{usn.getURL()}\n"

refs = usn.getReferences.split(",")
print "Referrence: \n"
refs.each do |c|
  print " * http://people.ubuntu.com/~ubuntu-security/cve/#{c}\n"
end
print "Details: \n \{\{\{\n #{usn.getDetails()} \n \}\}\}\n"
