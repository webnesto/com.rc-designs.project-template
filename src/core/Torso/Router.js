var Torso = Torso || {};
Torso.Router = ( function(){

	// simplified $.deparam analog
	// function deparam (paramString){
		// var result = {};
		// if( ! paramString){
			// return result;
		// }
		// $.each(paramString.split('&'), function(index, value){
			// if(value){
				// var param = value.split('=');
				// result[param[0]] = param[1];
			// }
		// });
		// return result;
	// };


	// var namedParam	= /=\w+/g;
	// var splatParam	= /\*\w+/g;
	// var escapeRegExp  = /[-[\]{}()+?.,\\^$|#\s]/g;

	return Backbone.Router.extend( {
		_extractParameters: function( route, fragment ) {
			var _intended = fragment.split( "&" )[ 0 ];
			var result = route.exec( _intended ).slice( 1 );
			return result;
		}
		// _extractParameters: function( route, fragment ) {
			// // log.debug( route, fragment );
			// // var _intended = fragment.split( "&" )[ 0 ];
			// log.debug( route.exec( fragment ) );
			// var result = route.exec( fragment ).slice( 1 );
			// return result;
			// // result.unshift( deparam( result[ result.length-1 ] ) );
			// // return result.slice( 0, -1 );
		// }
	// ,
		// _routeToRegExp: function( route ){
			// log.debug( "_routeToRegExp in: ", route );
			// route = route
				// .replace(escapeRegExp, '\\$&')
				// .replace(namedParam, '=([^&]+)&?.*')
				// .replace(splatParam, '(.*?)')
			// ;
			// log.debug( "_routeToRegExp out: ", route );
			// return new RegExp( route );
		// }
	} );
}() );