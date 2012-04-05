require(
    [
        // "com.rc-designs/models/foo"
    // ,
    	"com.rc-designs/views/Foo/Foo"
    ]
,   function(
        // fooModel
    // ,
    	Foo
    ){
    	var
    		_foo
    	;

	    $( document ).ready( function(){
	        new ( Torso.Router.extend( {
		    	routes: {
		    		"foo/:id": "showThing"
		    	,	"foo/:id/:cow": "showThing"
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

	        } ) )();
	        Backbone.history.start();
	    } );
	}
);