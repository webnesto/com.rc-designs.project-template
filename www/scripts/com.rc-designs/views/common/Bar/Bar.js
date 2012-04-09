define(
	[
		"com.rc-designs/views/View"
	,	"lib/text!./Bar.html"
	]
,	function(
		View
	,	html
	){
		var _View;
		var _defaults = {

		};

		_View = View.extend( {
			initialize: function(){
				this._html = html;
				this._super();
			}
		//,	data: function( data ){
		//		log.debug( "DATA?", data );
		//		var _super = this._super( data );

		//		log.debug("SUPER FOO:", _super.get("foo") );

				

		//		return this._super( data );
		//	}
		} );

		//_View.test();

		return _View;
	}
);
