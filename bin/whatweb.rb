#!/usr/bin/env ruby
# encoding: utf-8

if ARGV[0].nil? then
  puts "Usage: ./whatweb.rb 1431791458"
  exit
end

require_relative '../lib/config'

task = ARGV[0]
input  = Cfg.get_path('masscan_db')+'ips.'+task
output = Cfg.get_path('whatweb_db')+'whatweb.'+task

if !File.exists?(input) then
  puts "Tid file not exist : #{input}"
  exit
end

cmd    = "whatweb --no-errors -t 255 -i #{input} --log-json=#{output} "
puts 'Running syscmd: '+cmd
result = `#{cmd}`
puts result

