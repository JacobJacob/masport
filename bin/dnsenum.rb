#!/usr/bin/env ruby
# encoding: utf-8

require_relative '../lib/sqlite'

if ARGV[0].nil? then
  puts "Usage: ./dnsenum.rb abc.com"
  exit
end

task   = ARGV[0]
output = Cfg.get_path('dnsenum_db')+task+'_out.xml'
dict_path = Cfg.get_path('config_dir')+'dns.txt'

cmd = Cfg.get('dnsenum_path')+" #{task} -f #{dict_path} -o #{output} "+Cfg.get('dnsenum_args')
puts 'Running syscmd: '+cmd

result = `#{cmd}`
puts result

