
class Conf < WEBrick::HTTPServlet::AbstractServlet

  def header(req, res)
    Basic_auth.authenticate req, res
    res['Content-Type'] = 'text/html'
    res.body += Header
  end

  def do_GET req, res
    header(req, res)

    acl_ports = ''
    acl_template = Cfg.get_path('db_dir') + 'acl_template.txt'
    if !File.exists?(acl_template) then
      acl_ports = "Acl template file not exist."
    else
      File.open(acl_template).each do |line|
        acl_ports += line if line.strip.size > 0
      end
    end

    res.body += '<h2>Config</h2>'
    res.body += '<form action="/task" method="post">'
    res.body += '<hr><b>ACL Template</b><br/>'
    res.body += '<textarea  rows="16" cols="48" name="acl_template">'+acl_ports+'</textarea><br />'
    res.body += '<input type="submit" value="Edit Config"><br />'
    res.body += '</form><br />'
  
    res.body += Footer
  end

  def do_POST req, res 
    header(req, res)
    
    acl = req.query['acl_template']
    return if acl.nil? 

    res.body += 'Add Task OK! '+ipaddr
    res.body += Footer
  end

end

