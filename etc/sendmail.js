var smtp = require('smtp-protocol');
var server_proto = require('./node_modules/smtp-protocol/lib/server/proto');
var seq = require('seq');
var fs = require('fs');
var tls = require('tls');

//var stream = net.createConnection(465, "smtp.gmail.com")

function tls_connect(host, port, cb) {

	var stream = tls.connect(port, host, function () {

		console.log('connected');

		oldwrite = stream.write;

		stream.write = function () {
			console.log("write:", [].slice.apply(arguments).toString().trim());
			oldwrite.apply(this, arguments);
		};

		stream.on('data', function (data) {
			console.log("read:", data.toString().trim());
		});

	});

	cb(server_proto(stream));
}


function tls_upgrade(socket, options, cb) {

	var sslcontext = require('crypto').createCredentials(options);

	var pair = require('tls').createSecurePair(sslcontext, false);

	var cleartext = tls_pipe(pair, socket);

	pair.on('secure', function () {
		var verifyError = pair.ssl.verifyError();

		if (verifyError) {
			cleartext.authorized = false;
			cleartext.authorizationError = verifyError;
		} else {
			cleartext.authorized = true;
		}

		if (cb) cb();
	});

	cleartext._controlReleased = true;
	return cleartext;
}

function tls_pipe(pair, socket) {
	pair.encrypted.pipe(socket);
	socket.pipe(pair.encrypted);

	pair.fd = socket.fd;
	var cleartext = pair.cleartext;
	cleartext.socket = socket;
	cleartext.encrypted = pair.encrypted;
	cleartext.authorized = false;

	function onerror(e) {
		if (cleartext._controlReleased) {
			cleartext.emit('error', e);
		}
	}

	function onclose() {
		socket.removeListener('error', onerror);
		socket.removeListener('close', onclose);
	}

	socket.on('error', onerror);
	socket.on('close', onclose);

	return cleartext;
}

console.log('connecting..');

var options = {
	tls: {
		secureConnectListener: function(s) {
			console.log("secureConnect", s.authorized, s.authorizationError);
			return s.authorized;
		},
		options: {
			ca: []
		}
	}
};

// smtps: smtp.gmail.com:465


smtp.connect(465, "smtp.gmail.com", options, function (mail) {
	seq()
		.seq_(function (next) {
			console.log("waiting for greeting");
			mail.on('greeting', function (code, lines) {
				console.log('greeting', arguments);
				next();
			});
		})
		.seq(function () {
			mail.helo('localhost', this.into('helo'));
		})
		.seq(function () {
			console.log('<helo', arguments);
			mail.from('bananas@zynga.com', this.into('from'));
		})
		.seq(function () {
			console.log('<from', arguments);
			mail.to('niall.smart@gmail.com', this.into('to'));
		})
		.seq(function () {
			console.log('<to', arguments);
			mail.data(this.into('data'))
		})
		.seq(function () {
			console.log('<data', arguments);
			mail.message(fs.createReadStream('./message'), this.into('message'));
		})
		.seq(function () {
			console.log('<data', arguments);
			mail.quit(this.into('quit'));
		})
		.seq(function () {
			console.log('<quit', arguments);
			console.dir(this.vars);
		})
	;
});
