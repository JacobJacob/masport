#!/usr/bin/env ruby
# encoding: utf-8

require_relative '../lib/sqlite'

running_tasks = SqliteDB.execute("select * from mastask where status<>'create' and status<>'finish'")
puts "running: #{running_tasks.size}"

if running_tasks.size < 1

  waiting_tasks = SqliteDB.execute("select * from mastask where status='create'")
  task = waiting_tasks.pop
  tid  = task[1]
  puts "next: #{tid}"
  cmd = "rake run tid=#{tid}"
  puts cmd
  result = `#{cmd}`

end
