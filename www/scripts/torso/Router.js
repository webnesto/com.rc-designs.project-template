define( function(){
	return Backbone.Router.extend( {
		_extractParameters: function( route, fragment ) {
			var _intended = fragment.split( "&" )[ 0 ];
			var result = route.exec( _intended ).slice( 1 );
			return result;
		}
	} );
} );