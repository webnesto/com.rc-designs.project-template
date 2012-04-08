define ( function(){
	var
		_defaults = {
			Model: Backbone.Model
		}
	;

	return Backbone.View.extend( {
		/**
		 * @constructor
		 * @param  {Object} inits Initial data, defaults, options, etc.
		 * @return {Torso.View}      View extension of Backbone.View
		 */
		initialize: function( inits ){
			var _inits = inits || {};
			var _opts = _inits._opts || [];
			var _defopts = _inits._defaults || [];

			_defopts.push( _defaults ); // push this default to the end of the defaults chain (want child Classes to be able to override)
			_opts = _defopts.concat( _opts ); // stick opts on the end ( augment rahter than override )
			_opts.unshift( {} ); //want an empty object at the front, don't wanna muck up any of the original objects.

			this._super();

			this._ = $.extend.apply( this, _opts ); //{}, _defaults, this._opts || {} );

			this._needAttach = true;

			this._template = false;

			this.model( _inits.data );

		}

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
			$( this.el ).html( this.template( this.model().toJSON() ) );
			log.debug( this.model().toJSON() );
			log.debug( this.template( this.model().toJSON() ) );
			this.append();
			return this;
		}

	,	append: function(){
			if( this._needAttach ){
				log.debug( "append!", this.el, this.container() );
				$( this.container() ).append( this.el );
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

	}
,	{
		test: function(){
			log.debug( "this is a test" );
		}
	} );
} );
