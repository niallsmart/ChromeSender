
var Seq = require('seq');

Seq()
	.seq(function() {
		this(null, 1, 2, 3, 4)
	})
	.seqEach(function(x) {
		console.log("seqEach.stack", this.stack);
		console.log("seqEach.args", this.args);
		console.log("seqEach.arguments", [].slice.apply(arguments));
		this(null, x * 2);
	})
	.seq(function(x) {
		console.log("seq.stack", this.stack);
		console.log("seq.arguments", [].slice.apply(arguments));
		//this(null, x * 2);
		this.into("doubles")
		this(null, x * 2)
	})
	.seqFilter(function(x) {
		console.log("seqFilter", [].slice.apply(arguments));
		this(x % 4, x);
	})
	.seq(function() {
		console.log("done.arguments", [].slice.apply(arguments));
		console.log("done.doubles", this.vars.doubles) 
		console.log("done");
	});
