Handlebars.registerHelper( 
	'foo', 
	function(object) {
		return new Handlebars.SafeString(
			'<span>' + object.foo + '</span>'
		);
	} 
);