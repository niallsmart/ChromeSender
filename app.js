/**
 * Module dependencies.
 */

var express = require('express'),
	coffeeScript = require('coffee-script');
	less = require('less');

global.app = module.exports = express.createServer();

// Configuration

app.configure(function () {
	app.set('views', __dirname + '/views');
	app.set('view engine', 'jade');
	app.set("view options", { layout: false });
	app.use(express.bodyParser());
	app.use(express.methodOverride());
	app.use(express.compiler({
		src: __dirname + '/views',
		dest: __dirname + '/compiled',
		enable: ['less', 'coffeescript']
	}));
	app.use(express.logger({ format: ':method :url' }));
	app.use(app.router);
	app.use(express.static(__dirname + '/public'));
	app.use(express.static(__dirname + '/compiled'));
});

app.configure('development', function () {
	app.use(express.errorHandler({ dumpExceptions:true, showStack:true }));
});

app.configure('production', function () {
	app.use(express.errorHandler());
});

// Routes

require('./api/api.coffee');

app.listen(3000);

console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);

