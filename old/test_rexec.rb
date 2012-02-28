#!/usr/bin/env ruby

# Copyright (c) 2007, 2009 Samuel Williams. Released under the GNU GPLv3.

require 'rubygems'
require 'rexec'

CLIENT = <<EOF
$connection.run do |path|
  listing = []
  IO.popen("ls -la " + path.dump, "r+") do |ls|
    listing = ls.readlines
  end
  $connection.send(listing)
end
EOF

command = ARGV[0] || "ruby"
puts "Starting server..."
RExec::start_server(CLIENT, command) do |conn, pid|
  puts "Sending path..."
  conn.send("/")

  puts "Waiting for response..."
  listing = conn.receive

  puts "Received listing:"
  listing.each do |entry|
    puts "\t#{entry}"
  end
end