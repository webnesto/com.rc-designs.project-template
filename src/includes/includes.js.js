( function( global ){

	var _includes = [
		"/js/bin/core.js"
// #ifdef dev
	,	"/js/bin/dev.js"
// #endif
	];
	var i;
	var l = _includes.length;

	for( i = 0; i < l; i++ ){
		document.write('<scr'+'ipt type="text/javascript" src="' + _includes[ i ] + '"></scr'+'ipt>');
	}

}( this ) );