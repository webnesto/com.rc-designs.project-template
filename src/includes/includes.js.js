( function(){
	var includes = [
		"/js/bin/core.js"
// #ifdef dev
	,	"/js/bin/dev.js"
// #endif
	// ,	"/scripts/require.js"
	];
	var i;
	var l = includes.length;

	for( i = 0; i < l; i++ ){
		document.write('<scr'+'ipt type="text/javascript" src="' + includes[ i ] + '"></scr'+'ipt>');
	}

	//document.write('<scr'+'ipt type="text/javascript" src="/js/lib/require.js" data-main="' + pageJSPath + '"></scr'+'ipt>');


}() );