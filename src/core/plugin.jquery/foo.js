(function( $ ){

	$.fn.foo = function( options ) {
		
	 // Create some defaults, extending them with any options that were provided
		var settings = $.extend( {
			'foo'				 : 'foo'
		}, options);

    // do some stuff here

		return this;
	};

})( jQuery );