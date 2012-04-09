Handlebars.registerHelper(
	'bar',
	function( str ) {
		return new Handlebars.SafeString(
			'<span>' + str.toUpperCase() + '</span>'
		);
	}
);