define(
	[
		"com.rc-designs/views/View"
	,	"lib/text!./Foo.html"
	]
,	function(
		View
	,	html
	){
		return View.extend( {
			_html: html
		} );
	}
);
