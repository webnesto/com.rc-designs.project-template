define(
	[
		"[baseView]"
	,	"lib/text!./[ViewName].html"
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
