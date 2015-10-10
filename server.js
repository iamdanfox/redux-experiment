var express = require('express');
var app = express();

app.use('/node_modules', express.static(__dirname + '/node_modules'));
app.use('/dist', express.static(__dirname + '/dist'));


app.get('*', function (req, res) {
  res.sendFile(__dirname + '/index.html', {headers: {'Content-type':'text/html'}});
});

var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening at http://%s:%s', host, port);
});
