$( document ).on( "ready", function(){
	less.watch();

	var host = window.location.host;
	var protocol = window.location.protocol;
	var keyPrefix = protocol + '//' + host + '/css/bin/';

	for (var key in window.localStorage) {
		if (key.indexOf(keyPrefix) === 0) {
			delete window.localStorage[key];
		}
	}
} );