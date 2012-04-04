define( function(){
	var
		_defaults = {
			Model: Backbone.Model
		,	container: function(){
				return document.body;
			}
		}
	;

	return Backbone.View.extend( {
		initialize: function( data ){

			this._super();

			this._ = $.extend( {}, _defaults, this._opts || {} );

			this._needAttach = true;

			this._template = false;

			this.model( data );

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
			$( this.el ).html( this.template( this.model().toJSON() ) );
			this.append();
			return this;
		}

	,	append: function(){
			if( this._needAttach ){
				log.debug( this.el, this._.container );
				$( this._.container() ).append( this.el );
				this._needAttach = false;
			}
			return this;
		}

	,	model: function( data ){
			if( ! this._model ){
				this._model = new this._.Model();
				this._model.bind( "change", this.render, this );
			} else
			if( typeof data !== "undefined" ){
				this._model.set( data );
			}

			return this._model;
		}

	} );
} );