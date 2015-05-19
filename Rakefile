path = File.dirname(__FILE__)

desc "Default"
task :default do
  system(path+'/bigweb.rb log')
end

desc "run dnsenum"
task :dns do
  domain = ENV['domain']
  syscmd = "cd #{path}/db/dns/ && nohup ruby #{path}/bin/dnsenum.rb #{domain} > #{path}/log/dnsenum.#{domain}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run masscan"
task :scan do
  tid = ENV['tid']
  #syscmd = "ruby #{path}/bin/masscan.rb #{tid}"
  syscmd = "nohup ruby #{path}/bin/masscan.rb #{tid} > #{path}/log/masscan.#{tid}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run whatweb"
task :whatweb do
  tid = ENV['tid']
  syscmd = "nohup ruby #{path}/bin/whatweb.rb #{tid} > #{path}/log/whatweb.#{tid}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run web"
task :web do
  syscmd = "ruby #{path}/web/main.rb"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "stop masport"
task :stop do
  syscmd = "ps aux | grep masport | grep -v grep  | awk '{print $2}' | xargs -n 1 kill -9 "
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "ps bigweb"
task :ps do
  syscmd = "ps aux | grep masport | grep -v grep "
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "WC"
task :wc do
  rb_files = `find ./ -name "*.rb" |wc -l`
  lines = `find ./ -name "*.rb" | xargs cat | grep -v ^$|wc -l`
  puts "Files: #{rb_files} Lines: #{lines}"
end
