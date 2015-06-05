#!/usr/bin/env ruby

require 'webrick'
require 'json'
require "digest/md5"
require_relative './task'
require_relative './conf'
require_relative './auth'
require_relative './str'
require_relative '../lib/sqlite'
require_relative '../lib/config'

#log_file = File.open '/tmp/webrick.log', 'a'
#log = WEBrick::Log.new log_file

server=WEBrick::HTTPServer.new :Port => 8000#, :Logger=>log#, :AccessLog=>access_log

# Keyborad Int
trap 'QUIT' do server.shutdown end 

# Database init
SqliteDB.init()

# Index Page
server.mount_proc "/" do |req, res|
	Basic_auth.authenticate req, res
	res['Content-Type'] = 'text/html'
	res.body += Header
	res.body += Index	
	res.body += Footer
end

server.mount_proc "/add" do |req, res|
	Basic_auth.authenticate req, res
	res['Content-Type'] = 'text/html'
	res.body += Header
	res.body += Add
	res.body += Footer
end

# Task Show
server.mount '/task', Task
server.mount '/conf', Conf

#WEBrick::Utils.su 'nobody'
WEBrick::Daemon.start
server.start

