# encoding: utf-8

class Task < WEBrick::HTTPServlet::AbstractServlet

  def header(req, res)
    Basic_auth.authenticate req, res
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

  def list_task()
    body = '<h2>Task List</h2>'
    tasks = SqliteDB.execute("select * from mastask")
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Ipaddr</th>'
    body += '<th>Port</th>'
    body += '<th>Status</th>'
    body += '<th>Time</th>'
    body += '<th>Data</th>'
    body += '<th>Act</th>'
    body += '</tr>'
    tasks.each do |task|
     body += '<tr>'
      body += '<td> '+task[0].to_s+'</td>'
      body += '<td> '+task[1].to_s+'</td>'
      body += "<td title='#{task[2].to_s}'> "+task[2].to_s[0..12]+'..</td>'
      body += "<td title='#{task[3].to_s}'> "+task[3].to_s[0..8]+'..</td>'
      #body += '<td title="test"> '+task[3].to_s+'</td>'
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
    body = '<h2>Masscan</h2>'
    count = 0
    output = Cfg.get_path('masscan_db') + 'ips.' + tid
    if !File.exists?(output) then
      return "Tid file not exist."
    end

    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Ipaddr</th>'
    body += '<th>Port</th>'
    body += '<th>Status</th>'
    body += '</tr>'

    File.open(output).each do |line|
      count += 1
      body += '<tr>'
      body += "<td>#{count}</td>"
      body += "<td>#{tid}</td>"
      body += "<td>#{line.split(':')[0]}</td>"
      body += "<td>#{line.split(':')[1]}</td>"
      body += "<td>open</td>"
      body += '</tr>'
    end
    body += '</table>'
    #body += "Count: #{count} <br/>"

    return body
  end

  def whatweb_task(tid)
    output = Cfg.get_path('whatweb_db') + 'whatweb.' + tid
    file = ''
    body = '<h2>Whatweb</h2>'
    if !File.exists?(output) then
      return "Tid file not exist."
    end
    
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Url</th width="20">'
    body += '<th>Data</th>'
    body += '</tr>'
    
    # 生成的格式rubyhash json无法识别，进行一些处理
    File.open(output).each do |line|
      file += line+','
    end
    file = '['+file[0..-2]+']'
    data_hash = JSON.parse(file)
    # end path
    count = 0
    data_hash.each do |data|
      count += 1
      plug = ''
      data['plugins'].each do |key,value|
        plug += " #{key}: #{value['string']} "
      end

      plug.gsub!('WWW-Authenticate','<font color="blue">WWW-Authenticate</font>')
      plug.gsub!('X-Powered-By','<font color="blue">X-Powered-By</font>')
      plug.gsub!('Tengine','<font color="green">Tengine</font>')
      plug.gsub!('Nginx','<font color="green">Nginx</font>')
      plug.gsub!('nginx','<font color="green">nginx</font>')
      plug.gsub!('Apache','<font color="green">Apache</font>')
      plug.gsub!('login','<font color="red">login</font>')
      plug.gsub!('manager','<font color="red">manager</font>')
      plug.gsub!('jenkins','<font color="red">jekins</font>')
      plug.gsub!('登陆','<font color="red">登陆</font>')
      plug.gsub!('管理','<font color="red">管理</font>')
      plug.gsub!('admin','<font color="red">admin</font>')
      plug.gsub!(/password/i,'<font color="red">password</font>')

      body += '<tr>'
      body += "<td>#{count}</td>"
      body += "<td width='20'><a title='#{data['target']}' href='#{data['target']}'>#{data['target'][0..32]}</a></td>"
      body += "<td>#{plug}</td>"
      body += '</tr>'
    end
    body += '</table>'
    return body
  end

  def nmap_task(tid)
    body = '<h2>Nmap</h2>'
    output = Cfg.get_path('nmap_db') + 'nmap.' + tid
    if !File.exists?(output) then
      return "Tid file not exist."
    end

    web_port = []
    know_port = []
    other_port = []
    ary = ['smtp','mysql','ssh','telnet','ftp','nfs','redis','pop','snmp','domain']
    File.open(output).each do |line|
      if !line.start_with?('#') and !line.include?('Status: Up')
        if line.include?('http') or line.include?('https')
          web_port << line
        #elsif line.include?('smtp') or line.include?('mysql') or line.include?('ssh') or line.include?('telnet') or line.include?('pop') or line.include?('snmp') or line.include?('ftp')
        elsif ary.any?{|word|line.include?(word)}
          know_port << line
        else
          other_port << line
        end
      end
    end

    body += '<ul class="nav nav-tabs" id="myTab"> '
    body += '<li class="active"><a href="#web_port"  data-toggle="tab">WEB端口</a></li> '
    body += '<li><a href="#know_port" data-toggle="tab">已知端口</a></li> '
    body += '<li><a href="#other_port" data-toggle="tab">其他端口</a></li> '
    body += '</ul> '
    body += '<div class="tab-content"> '

    # WEB端口
    count = 0
    body += '<div class="tab-pane active" id="web_port">'
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Data</th>'
    body += '</tr>'
    web_port.each{|line|
        count += 1
        body += '<tr>'
        body += "<td>#{count}</td>"
        body += "<td>#{tid}</td>"
        body += "<td>#{line.split('(')[0]}</td>"
        body += "<td>#{line.split(')')[1]}</td>"
        body += '</tr>'
    }
    body += '</table>'
    body += "</div>"

    # 已知端口
    count = 0
    body += '<div class="tab-pane" id="know_port">'
    body += "<p>#{ary.join(', ')}</p>"
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Data</th>'
    body += '</tr>'
    know_port.each{|line|
        count += 1
        body += '<tr>'
        body += "<td>#{count}</td>"
        body += "<td>#{tid}</td>"
        body += "<td>#{line.split('(')[0]}</td>"
        body += "<td>#{line.split(')')[1]}</td>"
        body += '</tr>'
    }
    body += '</table>'
    body += "</div>"

    # 已知端口
    count = 0
    body += '<div class="tab-pane" id="other_port">'
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Data</th>'
    body += '</tr>'
    other_port.each{|line|
        count += 1
        body += '<tr>'
        body += "<td>#{count}</td>"
        body += "<td>#{tid}</td>"
        body += "<td>#{line.split('(')[0]}</td>"
        body += "<td>#{line.split(')')[1]}</td>"
        body += '</tr>'
    }
    body += '</table>'
    body += "</div>"

    return body
  end

  def prot_audit_task(tid)
    body = '<h2>PortAudit</h2>'
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
    web_acl = []
    out_acl = []
    scan_ports.each do |item|
      if acl_ports.include? item
        in_acl << item
      elsif item.end_with?(':80') or item.end_with?('443')
        web_acl << item
      else
        out_acl << item
      end
    end

    # 过期ACL
    expired_acl = acl_ports - in_acl
    #body += "acls.size #{acl_ports.size}<br/>"
    #body += "scan.size #{scan_ports.size}<br/>"

    body += '<ul class="nav nav-tabs" id="myTab"> '
    body += '<li class="active"><a href="#home"  data-toggle="tab">合法ACL</a></li> '
    body += '<li><a href="#expired_acl" data-toggle="tab">过期ACL</a></li> '
    body += '<li><a href="#profile" data-toggle="tab">非法WEB ACL</a></li> '
    body += '<li><a href="#messages" data-toggle="tab">非法ACL</a></li> '
    body += '</ul> '
    body += '<div class="tab-content"> '
    
    # in acl
    body += '<div class="tab-pane active" id="home">'
    body += '<p>扫描全部开放端口,在访问控制列表中允许开放端口</p>'
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Port</th>'
    body += '</tr>'
    count = 0
    in_acl.each{|i|
      count += 1
      body += '<tr>'
      body += "<td>#{count}</td>"
      body += "<td>#{tid}</td>"
      body += "<td>#{i.split(':')[0]}</td>"
      body += "<td>#{i.split(':')[1]}</td>"
      body += '</tr>'
    }
    body += '</table>'
    body += "</div>"

    # expired acl
    body += '<div class="tab-pane" id="expired_acl">'
    body += '<p>在访问控制列表中允许开放端口，但是在实际扫描中未开启或者已下线的端口</p>'
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Port</th>'
    body += '</tr>'
    count = 0
    expired_acl.each{|i|
      count += 1
      body += '<tr>'
      body += "<td>#{count}</td>"
      body += "<td>#{tid}</td>"
      body += "<td>#{i.split(':')[0]}</td>"
      body += "<td>#{i.split(':')[1]}</td>"
      body += '</tr>'
    }
    body += '</table>'
    body += "</div>"
    
    # out acl web
    body += '<div class="tab-pane" id="profile">'
    body += '<p>扫描全部开放端口,在访问控制列表中不存在WEB端口</p>'
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Port</th>'
    body += '</tr>'
    count = 0
    web_acl.each{|i|
      count += 1
      body += '<tr>'
      body += "<td>#{count}</td>"
      body += "<td>#{tid}</td>"
      body += "<td>#{i.split(':')[0]}</td>"
      body += "<td>#{i.split(':')[1]}</td>"
      body += '</tr>'
    }
    body += '</table>'
    body += "</div>"
    
    # out acl 
    body += '<div class="tab-pane" id="messages">'
    body += '<p>扫描全部开放端口,在访问控制列表中不存在其他端口</p>'
    body += '<table style="width:100%" class="table table-bordered table-hover table-striped">'
    body += '<tr>'
    body += '<th>Id</th>'
    body += '<th>Tid</th>'
    body += '<th>Host</th>'
    body += '<th>Port</th>'
    body += '</tr>'
    count = 0
    out_acl.each{|i|
      count += 1
      body += '<tr>'
      body += "<td>#{count}</td>"
      body += "<td>#{tid}</td>"
      body += "<td>#{i.split(':')[0]}</td>"
      body += "<td>#{i.split(':')[1]}</td>"
      body += '</tr>'
    }
    body += '</table>'
    body += "</div>"
    body += '</div> '
    
    return body
  end

end

