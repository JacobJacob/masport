# encoding: utf-8

require "sqlite3"
require_relative 'config'

class SqliteDB

  @@db  = SQLite3::Database.new Cfg.get_path('sqlite_db')
  @@mux = Mutex.new

  def self.init()
    self.execute ''' 
      CREATE TABLE IF NOT EXISTS mastask (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        tid char(32),
        ipaddr varchar(255),
        ports varchar(1024),
        status varchar(128),
        data text,
        start_time TimeStamp NOT NULL DEFAULT CURRENT_TIMESTAMP, 
        stop_time TimeStamp
      ); 
    '''
  end

  def self.update_status(tid, stat)
    self.execute("update mastask set status='#{stat}' where tid='#{tid}' ")
  end

  def self.execute(sql, ary=nil)
    @@mux.synchronize{
      begin
        if ary then
          @@db.execute(sql, ary)
        else
          @@db.execute(sql)
        end
      rescue SQLite3::BusyException => e
        puts('Sqlite busy...')
        sleep 0.5
        retry
      end
    }
  end

end

