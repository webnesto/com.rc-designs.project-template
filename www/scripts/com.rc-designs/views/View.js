/**
 * App specific View methods go here.
 */

define(
	[
		"torso/View"
	]
,	function(
		View
	){

	return View.extend(
		/**
		 * Instance prototype inheritance
		 */
		{
			/**
			 * Example of overriding the container a view is attached to by default.
			 * Torso defines the default container as "document.body" - as we have a "#main" div
			 * in our html - we've added this container default.
			 *
			 * @return {jQuery} Single id selected div
			 */
			container: function(){
				return $( "#main" );
			}
		}
	);
} );