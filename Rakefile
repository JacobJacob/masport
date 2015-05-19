path = File.dirname(__FILE__)

desc "Default"
task :default do
  system(path+'/bigweb.rb log')
end

desc "run dnsenum"
task :dnsenum do
  domain = ENV['domain']
  syscmd = "cd #{path}/db/dnsenum/ && ruby #{path}/bin/dnsenum.rb #{domain}"
  #syscmd = "cd #{path}/db/dnsenum/ && nohup ruby #{path}/bin/dnsenum.rb #{domain} > #{path}/log/dnsenum.#{domain}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run masscan"
task :masscan do
  tid = ENV['tid']
  syscmd = "ruby #{path}/bin/masscan.rb #{tid}"
  #syscmd = "nohup ruby #{path}/bin/masscan.rb #{tid} > #{path}/log/masscan.#{tid}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run whatweb"
task :whatweb do
  tid = ENV['tid']
  syscmd = "ruby #{path}/bin/whatweb.rb #{tid}"
  #syscmd = "nohup ruby #{path}/bin/whatweb.rb #{tid} > #{path}/log/whatweb.#{tid}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run nmap"
task :nmap do
  tid = ENV['tid']
  syscmd = "ruby #{path}/bin/nmap.rb #{tid}"
  #syscmd = "nohup ruby #{path}/bin/nmap.rb #{tid} > #{path}/log/nmap.#{tid}.log  2>&1 &"
  puts "Running syscmd: #{syscmd}"
  system(syscmd)
end

desc "run all"
task :run do
  Rake::Task['masscan'].invoke
  Rake::Task['whatweb'].invoke
  Rake::Task['nmap'].invoke
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

