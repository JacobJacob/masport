
Header = '''<html>
<head>
<meta charset="utf-8"/>
<title>Masport</title>
<link href="http://cdn.bootcss.com/bootstrap/3.3.0/css/bootstrap.min.css" rel="stylesheet">
<script src="http://cdn.bootcss.com/jquery/1.11.2/jquery.min.js"></script>
<script src="http://cdn.bootcss.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
</head>
<body>

<nav class="navbar navbar-inverse">
  <div class="container">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="#">Masprot</a>
    </div>
    <div id="navbar" class="collapse navbar-collapse">
      <ul class="nav navbar-nav">
        <li class="active.bk"><a href="/task">Task</a></li>
        <li><a href="/add">Add Task</a></li>
        <li><a href="#">About</a></li>
      </ul>
    </div><!--/.nav-collapse -->
  </div>
</nav>

<div class="container">
<div class="row">
<div class="col-md-12">
<!--h3><a href="/">-= Masport=-</a> <small>Web</small></h3-->
<!--a onclick="window.history.go(-1);">&lt;&lt;Back </a> | -->
<!--a href="/task"> Task List</a> | <a href="/add"> Task Add</a><br /><br /-->
'''

Footer = '''
</div>
</div>
</div>
</body>
</html>
'''

Index =  '''
'''

Add =  '''
<form action="/task" method="post">
<b>New Task : </b>
<input type="submit" value="Add Task >>"><br />
<textarea  rows="8" cols="48" name="ipaddr"></textarea><br />
<b>Port : </b><br />
<input name="port" value="80,81,8080,8081,8090" ><br /><br />
<b>Description : </b><br />
<input name="desc" ><br /><br />

<b>Example IP: </b><br />
192.168.0.1<br/>
10.0.0.0/8<br/>
10.0.0.1-10.0.0.254<br/>
<b>Example PORT: </b><br />
80<br/>
80,8080<br/>
1-65535<br/>

<b>Rake cmd: </b><br />
rake dnsenum domain=abc.com<br/>
rake masscan tid=x<br/>
rake whatweb tid=x<br/>
rake nmap tid=x<br/>

<br /><br />
</form><br />
'''
