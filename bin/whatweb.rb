#!/usr/bin/env ruby
# encoding: utf-8

if ARGV[0].nil? then
  puts "Usage: ./whatweb.rb 1431791458"
  exit
end

require 'json'
require_relative '../lib/sqlite'

task = ARGV[0]
output = Cfg.get_json_path+'masscan.'+task
winput = Cfg.get_json_path+'ippt.'+task
woutput = Cfg.get_json_path+'whatweb.'+task

if !File.exists?(output) then
  puts "Tid file not exist."
  exit
end

file = File.read(output)
# 生成的格式rubyhash json无法识别，进行一些处理
file = '['+file[0..-17]+']'
data_hash = JSON.parse(file)
puts "result.size: #{data_hash.size}"
data_hash.each do |data|
  data['ports'].each do |port|
    `echo #{data['ip']}:#{port['port']} >> #{winput}`
  end
end

cmd    = "whatweb --no-errors -t 255 -i #{winput} --log-json=#{woutput} "
puts 'Running syscmd: '+cmd
result = `#{cmd}`
puts result

