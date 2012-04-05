( function( global ){

	var rel = "stylesheet";
//#ifdef dev
	rel = "stylesheet/less";
//#endif
	var _includes = [
		"/css/bin/core.css"
	,	"/css/bin/com.rc-designs.css"
	];
	var i;
	var l = _includes.length;

	for( i = 0; i < l; i++ ){
		document.write('<link href="' + _includes[ i ] + '" rel="' + rel  + '" type="text/css" />');
	}

}( this ) );