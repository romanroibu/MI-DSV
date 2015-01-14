#!/usr/bin/env ruby
require 'optparse'

require './node'
require './server'

options = {}

OptionParser.new do |opts|
  # Set a banner, displayed at the top of the help screen
  opts.banner = "Usage: chat.rb host:node [connect_host:connect_port]"

  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Port number on which the node listens for connections' ) do
    options[:verbose] = true
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!

if ARGV.empty?
  puts "Invalid command invocation: no 'host:port' argument(s). Use --help flag to see how to use the script."
  exit
else
  node_address, next_address = *ARGV
end

node   = Node.new node_address, next_address
server = NodeServer.new node

server.start
