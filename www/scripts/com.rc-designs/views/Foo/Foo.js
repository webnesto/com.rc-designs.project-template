log.debug( "foo load begin" );
define(
	[
		"com.rc-designs/views/View"
	,	"lib/text!./Default.html"
	,	"lib/text!./Foo.html"
	]
,	function(
		View
	,	defaultHtml
	,	fooHtml
	){
		var _View;

		_View = View.extend( {
			initialize: function(){
				this._html = defaultHtml;
				this._super();
				// this._altTemplate = Handlebars.compile( defaultHtml );
				// this._offTemplate;
			}
		,	model: function( data ){
				log.debug( data );
				var _temp;
				if(
					data
				// && 	typeof data.foo !== "undefined"
				// && 	!data.foo
				&&	this._html == fooHtml
				){
					// log.debug("got no foo");
					// this._offTemplate = this._template;
					// this._template = this._altTemplate;
					this._html = defaultHtml;
					this._template = false;
					// data.foo = "moo";
				}
				else if( this._html == defaultHtml ){
					this._html = fooHtml;
					this._template = false;
				}


				return this._super( data );
			}
		} );

		_View.test()

		return _View;
	}
)
