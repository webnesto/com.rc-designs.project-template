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

					this._children = [];

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
					this.$el.html( this.template( this.data().toJSON() ) );
					this.append();
					return this;
				}

			,	show: function(){
					this.$el.show();
				}

			,	hide: function(){
					this.$el.hide();
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


			,	addChild: function( child ){
					var _that = this;
					
					child.view.container = function(){
						return _that.$( child.selector );
					};
					
					child.view._needAttach = true;
					
					this._children.push( child );

					return this;
				}

			,	addChildren: function( children ){
					var i, l;
					
					for( i = 0, l = chidren.length; i < l; i++ ){
						this.addChild( children[ i ] );
					}

					return this;
				}

			}

		);

		return _View;
	}
);
