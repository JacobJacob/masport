#!/usr/bin/env ruby
# encoding: utf-8

require "digest/md5"
require 'json'
require_relative 'lib/sqlite'

task   = Digest::MD5.hexdigest('test3').to_s
port   = '8080'
ipaddr = '101.227.22.0/24'
output = Cfg.get_json_path+'masscan.'+task
rate   = '10000'

cmd    = "masscan -v -p#{port} --rate=#{rate} -oJ #{output} #{ipaddr}"
puts cmd

result = `#{cmd}`
puts result

file = File.read(output)
# 生成的格式rubyhash json无法识别，进行一些处理
file = '['+file[0..-17]+']'
data_hash = JSON.parse(file)
puts "result.size: #{data_hash.size}"
#data_hash.each do |data|
#  data['ports'].each do |port|
#    puts "#{data['ip']}:#{port['port']}"
#  end
#end

# DB
SqliteDB.init
SqliteDB.execute("insert into mastask (tid,ipaddr,ports,status,data) values (?,?,?,?,?)", [task, ipaddr, port, 'init', output])

