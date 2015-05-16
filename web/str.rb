
Header = '''<html>
<head>
<meta charset="utf-8"/>
<title>Masport</title>
</head>
<body>
<link href="http://cdn.bootcss.com/bootstrap/3.3.0/css/bootstrap.min.css" rel="stylesheet">
<div class="container">
<div class="row">
<div class="col-md-12">
<h3><a href="/">-= Masport=-</a> <small>Web</small></h3>
<input type="button" value="<< Back" onclick="window.history.go(-1);">
<a href="/task"> Task List</a><br /><br />
'''

Footer = '''
</div>
</div>
</div>
</body>
</html>
'''

Index =  '''
<form action="/task" method="post">
<b>New Task : </b>
<input type="submit" value="Add Task >>"><br />
<textarea  rows="8" cols="48" name="ipaddr"></textarea><br />
<b>Port : </b><br />
<input name="port" value="80,81,8080,8081,8090" ><br /><br />

<b>Example IP: </b><br />
192.168.0.1<br/>
10.0.0.0/8<br/>
10.0.0.1-10.0.0.254<br/>
<b>Example PORT: </b><br />
80<br/>
80,8080<br/>
1-65535<br/>

<br /><br />
</form><br />
'''
