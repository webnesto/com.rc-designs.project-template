require(
    [
        "com.rc-designs/models/foo"
    ,	"com.rc-designs/views/Foo/Foo"
    ]
,   function(
        fooModel
    ,	Foo
    ){
    	var
    		_foo
    	;

        AppRouter = Torso.Router.extend( {

	    	routes: {
	    	    // "foo=id&poo=cow": "showThing"
	    	// ,    "poo=id&foo=cow": "showThing"
	    	// ,	"": "showDefault"
	    		"foo/:id" : "showThing"
	    	,	"foo/:id/:cow" : "showThing"
	    	,	"" : "showThing"
	    	}

		,	showDefault: function(){
				// show default
				log.debug( "default" );
			}

	    ,	showThing: function( foo, cow ) {
	    		log.debug( foo, cow );
	            //do a thing with a thing
	            if( !_foo ){
	            	_foo = new Foo();
	            }

	            _foo.model( { foo: foo, cow: cow } );

	      	}

        } );

	    $( document ).ready( function(){
	        app = new AppRouter();
	        Backbone.history.start();
	    } );
	}
);