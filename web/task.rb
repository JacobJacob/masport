
class Task < WEBrick::HTTPServlet::AbstractServlet

  def header(req, res)
  res['Content-Type'] = 'text/html'
  res.body += Header
  end

  def do_GET req, res
    header(req, res)
    del_tid = req.query['delid']
    masscan_tid = req.query['masscan_tid']
    whatweb_tid = req.query['whatweb_tid']
    nmap_tid = req.query['nmap_tid']
    port_tid = req.query['port_tid']
  
    if del_tid
      SqliteDB.execute("delete from mastask where tid='#{del_tid}'")
      res.body += 'Del Task OK!'
    elsif whatweb_tid
      res.body += whatweb_task(whatweb_tid)
    elsif masscan_tid
      res.body += masscan_task(masscan_tid)
    elsif nmap_tid
      res.body += nmap_task(nmap_tid)
    elsif port_tid
      res.body += prot_audit_task(port_tid)
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
    ipaddr = ipaddr.gsub(/\r\n/, ' ')
    return if (ipaddr =~ /^[\s\d,-\/]*$/).nil?
    port   = req.query['port']
    return if port.nil?
    return if (port =~ /^[\s\d,-\/]*$/).nil?

    task = Time.now.to_i
    SqliteDB.execute("insert into mastask (tid,ipaddr,ports,status,data) values (?,?,?,?,?)", [task, ipaddr, port, 'create', desc])

    res.body += 'Add Task OK! '+ipaddr
    res.body += Footer
  end

  def whatweb_task(tid)
    output = Cfg.get_path('whatweb_db') + 'whatweb.' + tid
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
      body += "<li><a href='#{data['target']}' >#{data['target']} #{}</a> <br/>"
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
      st = DateTime.parse task[6].to_s
      st = st.mday.to_s+'-'+st.hour.to_s+':'+st.min.to_s
      body += '<td> '+st+'<br />'+task[7].to_s+'</td>'
      body += '<td> '+task[5].to_s+'</td>'
      # Action
      body += "<td>"+action_str(task[1])+"</td>"
      body += '</tr>'
    end
    body += '</table>'
    return body
  end

  def action_str(tid)
    body = ''
    masscan_file = Cfg.get_path('masscan_db') + 'ips.' + tid
    masscan_file = false if !File.exists?(masscan_file)
    whatweb_file = Cfg.get_path('whatweb_db') + 'whatweb.' + tid
    whatweb_file = false if !File.exists?(whatweb_file)
    nmap_file = Cfg.get_path('nmap_db') + 'nmap.' + tid
    nmap_file = false if !File.exists?(nmap_file)

    if masscan_file
      body += "<a title='Masscan' href='/task?masscan_tid=#{tid}'>Masscan</a> "
    else
      body += "Masscan "
    end
    if whatweb_file
      body += "<a title='Whatweb' href='/task?whatweb_tid=#{tid}'>Whatweb</a> "
    else
      body += "Whatweb "
    end
    if nmap_file
      body += "<a title='Nmap' href='/task?nmap_tid=#{tid}'>Nmap</a> "
    else
      body += "Nmap "
    end

    body += "<a title='Portaudit' href='/task?port_tid=#{tid}'>PortAudit</a> "
    body += "<a title='Delete' style='color:red;' href='/task?delid=#{tid}'>Delete</a> "
    return body
  end

  def masscan_task(tid)
    body = ''
    count = 0
    output = Cfg.get_path('masscan_db') + 'ips.' + tid
    if !File.exists?(output) then
      return "Tid file not exist."
    end
    file = File.read(output)

    File.open(output).each do |line|
      count += 1
      body += line+'<br />'
    end
    body += "Count: #{count} <br/>"

    return body
  end

  def nmap_task(tid)
    body = ''
    count = 0
    output = Cfg.get_path('nmap_db') + 'nmap.' + tid
    if !File.exists?(output) then
      return "Tid file not exist."
    end
    file = File.read(output)

    File.open(output).each do |line|
      if !line.start_with?('#') and !line.include?('Status: Up')
        count += 1
        body += line+'<br />' 
      end
    end
    body += "Count: #{count} <br/>"

    return body
  end

  def prot_audit_task(tid)
    body = ''
    scan_port  =  Cfg.get_path('masscan_db') + 'ips.' + tid
    acl_port = Cfg.get_path('db_dir') + 'open-6-2.txt'
    if !File.exists?(scan_port) then
      return "Tid file not exist."
    end

    acl_ports = []
    File.open(acl_port).each do |line|
      acl_ports << line.chomp.strip
    end

    scan_ports = []
    File.open(scan_port).each do |line|
      scan_ports << line.chomp.strip
    end

    in_acl = []
    out_acl = []
    scan_ports.each do |item|
      if acl_ports.include? item
        in_acl << item
      else
        out_acl << item
      end
    end
    body += "acls.size #{acl_ports.size}<br/>"
    body += "scan.size #{scan_ports.size}<br/>"
    body += "<hr/>"
    body += "in acl:  #{in_acl.size}<br/>"
    in_acl.each{|i| body+="#{i}<br/>" }
    body += "<hr/>"
    body +=  "out acl: #{out_acl.size}<br/>"
    out_acl.each{|i| body+="#{i}<br/>" }

    return body
  end

end

