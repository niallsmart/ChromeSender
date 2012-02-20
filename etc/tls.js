net = require('net');
tls = require('tls');

var proto = tls;
//var proto = net;

host = "smtp.gmail.com";

if (proto == tls) {
	port = 465;
} else {
	port = 25;
}

var stream = proto.connect(port, host, function () {
	console.log('connected');

	stream.on('data', function (data) {
		console.log("read:", data.toString().trim());
	});

});

setTimeout(function() {
}, 1000);