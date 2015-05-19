#!/usr/bin/env ruby
# encoding: utf-8

require_relative '../lib/sqlite'

if ARGV[0].nil? then
  puts "Usage: ./dnsenum.rb abc.com"
  exit
end

task   = ARGV[0]
thread = '64'
output = Cfg.get_dns_path+task+'_out.xml'
dict_path = Cfg.get_config_path+'/dns.txt'

cmd    = "dnsenum #{task} -f #{dict_path} --nocolor --private --noreverse --threads #{thread} -o #{output}"
puts 'Running syscmd: '+cmd

result = `#{cmd}`
puts result
