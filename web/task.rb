
class Task < WEBrick::HTTPServlet::AbstractServlet

  def header(req, res)
  res['Content-Type'] = 'text/html'
  res.body += Header
  end

  def do_GET req, res
    header(req, res)
    del_tid = req.query['delid']
    show_tid = req.query['tid']
    whatweb_tid = req.query['whatweb_tid']
  
    if del_tid
      SqliteDB.execute("delete from mastask where tid='#{del_tid}'")
      res.body += 'Del Task OK!'
    elsif whatweb_tid
      res.body += whatweb_task(whatweb_tid)
    elsif show_tid
      res.body += get_task(show_tid)
    else
      res.body += list_task()
    end
  
    res.body += Footer
  end

  def do_POST req, res 
    header(req, res)
    
    desc = req.query['desc']
    desc = '' if desc.nil?
    ipaddr = req.query['ipaddr']
    return if ipaddr.nil?
    port   = req.query['port']
    return if port.nil?

    ipaddr = ipaddr.gsub(/\r\n/, ' ')
    task = Time.now.to_i
    SqliteDB.execute("insert into mastask (tid,ipaddr,ports,status,data) values (?,?,?,?,?)", [task, ipaddr, port, 'create', desc])

    res.body += 'Add Task OK! '+ipaddr
    res.body += Footer
  end

  def whatweb_task(tid)
    output = Cfg.get_json_path + 'whatweb.' + tid
    file = ''
    body = ''
    if !File.exists?(output) then
      return "Tid file not exist."
    end
    # 生成的格式rubyhash json无法识别，进行一些处理
    File.open(output).each do |line|
      file += line+','
    end
    file = '['+file[0..-2]+']'
    data_hash = JSON.parse(file)
    body += "Count: #{data_hash.size} <br/>"
    data_hash.each do |data|
      body += "<li> #{data['target']}: #{} <br/>"
      data['plugins'].each do |key,value|
        body += " #{key}: #{value['string']} "
      end
      body += '</li><hr/>'
    end
    return body
  end

  def list_task()
    body = ''
    tasks = SqliteDB.execute("select * from mastask")
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Ipaddr</th>'
    body += '<th>Port</th>'
    body += '<th>Status</th>'
    body += '<th>Start/Stop Time</th>'
    body += '<th>Data</th>'
    body += '<th>Act</th>'
    body += '</tr>'
    tasks.each do |task|
     body += '<tr>'
      body += '<td> '+task[0].to_s+'</td>'
      body += '<td> '+task[1].to_s+'</td>'
      body += '<td> '+task[2].to_s+'</td>'
      body += '<td> '+task[3].to_s+'</td>'
      body += '<td> '+task[4].to_s+'</td>'
      body += '<td> '+task[6].to_s+'<br />'+task[7].to_s+'</td>'
      body += '<td> '+task[5].to_s+'</td>'
      body += "<td><a href=\"/task?tid=#{task[1]}\">Masscan</a>  <a href=\"/task?whatweb_tid=#{task[1]}\">Whatweb</a> <a style='color:red;' href=\"/task?delid=#{task[1]}\">Delete</a></td>"
      body += '</tr>'
    end
    body += '</table>'
    return body
  end

  def get_task(tid)
    body = ''
    output = Cfg.get_json_path + 'masscan.' + tid
    if !File.exists?(output) then
      return "Tid file not exist."
    end
    file = File.read(output)

    # 生成的格式rubyhash json无法识别，进行一些处理
    file = '['+file[0..-17]+']'
    data_hash = JSON.parse(file)
    body += "Count: #{data_hash.size} <br/>"
    data_hash.each do |data|
      data['ports'].each do |port|
        body += "#{data['ip']}:#{port['port']} <br/>"
      end
    end
    return body
  end

end

