( function(){
	var rel = "stylesheet";
//#ifdef dev
	rel = "stylesheet/less";
//#endif
	var includes = [
		"/css/bin/core.css"
	,	"/css/bin/com.rc-designs.css"
	];
	var i;
	var l = includes.length;

	for( i = 0; i < l; i++ ){
		document.write('<link href="' + includes[ i ] + '" rel="' + rel  + '" type="text/css" />');
	}

}() );