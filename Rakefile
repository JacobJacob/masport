path = File.dirname(__FILE__)

desc "Default"
task :default do
  system(path+'/bigweb.rb log')
end

desc "run masscan"
task :scan do
  tid = ENV['tid']
  syscmd = "ruby #{path}/bin/masscan.rb #{tid}"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run whatweb"
task :whatweb do
  tid = ENV['tid']
  syscmd = "ruby #{path}/bin/whatweb.rb #{tid}"
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

