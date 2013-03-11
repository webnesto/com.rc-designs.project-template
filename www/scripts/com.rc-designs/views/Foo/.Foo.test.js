//>>includeStart("test", pragmas.test)
define(
	[
		"./Foo.js"
	]
,	function(
		View
	){
		return function(){
			with( jasmine ){
				describe( "Foo", function(){
					var foo;
					it( "should allow you to instantiate an instance", function(){
						foo = new View();
						expect(
							typeof foo !== "undefined"
						).toBeTruthy();
					} );
				} );
			}
		};
	}
);
//>>includeEnd("test")