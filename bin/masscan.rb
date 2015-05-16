#!/usr/bin/env ruby
# encoding: utf-8


if ARGV[0].nil? then
  puts "Usage: ./masport.rb 1431791458"
  exit
end

require_relative '../lib/sqlite'

task   = ARGV[0]
output = ''
ipaddr = ''
port   = ''
tasks  = SqliteDB.execute("select * from mastask where tid='#{task}'")

if tasks.size == 0 then
  puts "No Tid:#{task} in DB."
  exit
end

tasks.each do |task|
  output = Cfg.get_json_path+'masscan.'+task[1]
  ipaddr = task[2]
  port   = task[3]
end
rate   = '10000'

cmd    = "masscan -p#{port} --rate=#{rate} -oJ #{output} #{ipaddr}"
puts 'Running syscmd: '+cmd

result = `#{cmd}`
puts result

