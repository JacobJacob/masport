#!/usr/bin/env ruby


input = '../db/wfuzz/url.txt'
filter= ' | grep -v 1999 '
cmd = "cat ../db/whatweb/* | awk -F '\"' '{print $4}' #{filter} > #{input}"
puts 'Running syscmd: '+cmd
result = `#{cmd}`


File.open(input).each do |url|
  result = ''
  url.chomp!
  if url
    cmd="wfuzz -z file,../db/wfuzz/path.txt --hc 404,403,400,301,302,401 -t 20 #{url}/FUZZ/"
    #cmd="medusa -t 64 -w 1 -v 4 -M http -h #{ip} -n #{port} -U ../db/dict/user.txt -P ../db/dict/pass.txt #{arg_path}"
    puts 'Running syscmd: '+cmd
    result = `#{cmd}`

    if result and result.include?('admin')
      File.open('../db/wfuzz/result.txt', 'a') { |file| file.write(result) }
    end
    puts result
  end

end
