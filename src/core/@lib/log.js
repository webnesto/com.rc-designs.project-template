/**
 * Thanks to https://github.com/cpatik/console.log-wrapper for bits and pieces of this
 */
( function( global, log ){
	var
		config = log || {}
	,	log = {
			log: function(){}
		,	debug: function(){}
		,	info: function(){}
		,	warn: function(){}
		,	error: function(){}
		}
	;

	//#ifdef debug
	var
		tries = 0
	;

	function hasFBL(){
		if (
			document.getElementById('firebug-lite')
		&&	hasConsole()
		){
			global.log = console;
			setConfig();
		} else if ( tries < 15 ){
			tries++;
			setTimeout( hasFBL, 2000 );
		}
	}

	function hasConsole(){
		return (
			typeof console != 'undefined'
		&& 	typeof console.log == 'function'
		&&	typeof console.debug == 'function'
		&&	typeof console.warn == 'function'
		&&	typeof console.error == 'function'
		&&	typeof console.info == 'function'
		);
	}

	function setConfig(){
		for( var prop in config ){
			if( config[ prop ] === false ){
				global.log[ prop ] = function(){};
			}
		}
	}

	// Tell IE9 to use its built-in console
	if (Function.prototype.bind && console && typeof console.log == "object") {
		["log","info","warn","error","assert","dir","clear","profile","profileEnd"]
			.forEach(function (method) {
				console[method] = this.call(console[method], console);
			}, Function.prototype.bind);
	}

	/*
	 * default behavior is to just proxy the console commands to console so as to not mess
	 * with normal console behavior (providing line nums, file locations, etc)
	 */
	if( !config.history ){

		if (
			hasConsole()
		){
			log = console;
		}
		else{
			if (!document.getElementById('firebug-lite')) {
				// Include the script
				var script = document.createElement('script');
				script.type = "text/javascript";
				script.id = 'firebug-lite';
				// If you run the script locally, point to /path/to/firebug-lite/build/firebug-lite.js
				script.src = 'https://getfirebug.com/firebug-lite.js';
				// If you want to expand the console window by default, uncomment this line
				//document.getElementsByTagName('HTML')[0].setAttribute('debug','true');
				document.getElementsByTagName('HEAD')[0].appendChild(script);
				setTimeout( hasFBL, 2000);
			}
		}
	}
	//#endif

	global.log = log;

	//#ifdef debug
	setConfig();
	//#endif

}( this, log ) );