define (
	[
		"torso/Model"
	]
,	function(
		Model
	){
		var _View;

		_View = Backbone.View.extend(
			{
				/**
				 * @constructor
				 * @param  {Object} inits Initial data, defaults, options, etc.
				 * @return {Torso.View}      View extension of Backbone.View
				 */
				initialize: function( inits ){
					var _inits = inits || {};

					this._super( inits );

					this._needAttach = true;

					this._template = false;

					if( _inits.data ) {
						this.data( _inits.data );
					}

				}

			,	_Model: Model

			,	container: function(){
					return document.body;
				}

			,	template: function(){
					if(
						!this._template
					||	(
							this._template.empty
						 &&	this._html
						)
					){
						if( this._html ){
							this._template = Handlebars.compile( this._html );
						}
						else {
							this._template = function(){};
							this._template.empty = true;
						}
					}
					return this._template.apply( this, arguments );
				}

			,	render: function(){
					$( this.el ).html( this.template( this.data().toJSON() ) );
					this.append();
					return this;
				}

			,	append: function(){
					if( this._needAttach ){
						$( this.container() ).append( this.el );
						this._needAttach = false;
					}
					return this;
				}

			,	data: function( data, options ){
					if( ! this.model ){
						this.model = new this._Model();
						this.model.on( "change", this.render, this );
					}
					if( typeof data !== "undefined" ){
						this.model.set( data, options );
					}

					return this.model;
				}
			}
		);

		return _View;
	}
);
