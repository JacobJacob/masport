#!/usr/bin/env ruby
# encoding: utf-8

if ARGV[0].nil? then
  puts "Usage: ./whatweb.rb 1431791458"
  exit
end

require_relative '../lib/config'
require_relative '../lib/sqlite'

task = ARGV[0]
SqliteDB.update_status(task,'what..')
input  = Cfg.get_path('masscan_db')+'ips.'+task
output = Cfg.get_path('whatweb_db')+'whatweb.'+task

if !File.exists?(input) then
  puts "Tid file not exist : #{input}"
  exit
end

cmd  = Cfg.get('whatweb_path')+" -i #{input} --log-json=#{output} "+Cfg.get('whatweb_args')
puts 'Running syscmd: '+cmd
result = `#{cmd}`
puts result

