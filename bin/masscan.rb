#!/usr/bin/env ruby
# encoding: utf-8

if ARGV[0].nil? then
  puts "Usage: ./masport.rb 1431791458"
  exit
end

require 'json'
require_relative '../lib/sqlite'

task   = ARGV[0]
SqliteDB.update_status(task,'mass..')
output = ''
ips_output = ''
ipaddr = ''
port   = ''
tasks  = SqliteDB.execute("select * from mastask where tid='#{task}'")

if tasks.size == 0 then
  puts "No Tid:#{task} in DB."
  exit
end

tasks.each do |task|
  output = Cfg.get_path('masscan_db')+'masscan.'+task[1]
  ips_output = Cfg.get_path('masscan_db')+'ips.'+task[1]
  ipaddr = task[2]
  port   = task[3]
end

cmd  = Cfg.get('masscan_path')+" -p#{port} -oJ #{output} #{ipaddr} "+Cfg.get('masscan_args')
puts 'Running syscmd: '+cmd

result = `#{cmd}`
puts result

file = File.read(output)
# 生成的格式rubyhash json无法识别，进行一些处理
file = '['+file[0..-17]+']'
data_hash = JSON.parse(file)
puts "result.size: #{data_hash.size}"
data_hash.each do |data|
  data['ports'].each do |port|
    `echo #{data['ip']}:#{port['port']} >> #{ips_output}`
  end
end

puts 'ips.'

