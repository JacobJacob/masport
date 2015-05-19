#!/usr/bin/env ruby
# encoding: utf-8

if ARGV[0].nil? then
  puts "Usage: ./nmap.rb 1431791458"
  exit
end

require_relative '../lib/config'
require_relative '../lib/sqlite'

task = ARGV[0]
SqliteDB.update_status(task,'nmap..')

input  = Cfg.get_path('masscan_db')+'ips.'+task
output = Cfg.get_path('nmap_db')+'nmap.'+task

if !File.exists?(input) then
  puts "Tid file not exist : #{input}"
  exit
end

File.open(input).each do |line|
  line.chomp!
  ary = line.split ':'
  ip = ary[0]
  port = ary[1]

  cmd = Cfg.get('nmap_path')+" #{ip} -p #{port} -oG #{output} --append-output "+Cfg.get('nmap_args')
  puts 'Running syscmd: '+cmd
  result = `#{cmd}`
  puts result
end

SqliteDB.update_status(task,'finish')
