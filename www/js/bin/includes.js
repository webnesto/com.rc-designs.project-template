/*! GENERATED FILE - DO NOT EDIT */
( function( global ){

	var rel = 'stylesheet';
	var _includes = [
		{ 
			item: '/css/bin/core.css' 
		,	extra: ''
		}
	// ,	{ 
	// 		item: '/css/bin/screen.css' 
	// 	,	extra: 'media="screen and (min-width : 640px)"'
	// 	}
	,	{ 
			item: '/css/bin/com.rc-designs.css' 
		,	extra: ''
		}
	];
	var i;
	var l = _includes.length;
	var inc;

	for( i = 0; i < l; i++ ){
		inc = _includes[ i ];
		document.write('<link href="' + inc.item + '" rel="' + rel  + '" ' + inc.extra + '  type="text/css" />');
	}

}( this ) );( function( global ){

	var _includes = [
		"/js/bin/core.js"
	];
	var i;
	var l = _includes.length;

	for( i = 0; i < l; i++ ){
		document.write('<scr'+'ipt type="text/javascript" src="' + _includes[ i ] + '"></scr'+'ipt>');
	}

}( this ) );