define( 
	[
		"torso/View"
	]
,	function(
		View
	){

	return View.extend( {
		container: function(){
			return $( "#main" );
		}
		

	}
,	{
		test: function(){
			this._super();
			log.debug( "this is a subtest" );
		}
	} );
} );