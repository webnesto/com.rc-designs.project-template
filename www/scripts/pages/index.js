require(
	[
		"torso/Router"
	,	"com.rc-designs/views/Foo/Foo"
    ]
,   function(
        Router    //:Router Base class
    ,	Foo       //:View for rendering
    ){
		var _foo;

		$( document ).ready( function(){
			new ( Router.extend( {
				routes: {
					"foo/:id": "showFoo"
				,	"foo/:id/": "showFoo"
				,	"foo/:id/:cow": "showFoo"
				,	"foo/:id/:cow/": "showFoo"

				// catch all (i.e. 404)
				,	"*any": "showError"
				}

			,	showFoo: function( foo, cow ) {
					//do a thing with a thing
					if( !_foo ){
						_foo = new Foo();
					}

					_foo.data(
						{
							foo: foo
						,	cow: cow
						}
					,	{
							silent: true
						}
					);

					_foo.render();
				}
				
			,	showError: function( any ){
					log.error( "nope", any );
					/* show some helpful view here directing user to correct url */
				}

			} ) )();

			Backbone.history.start();
		} );
	}
);