Web Project Template 1.0 Readme
===============================
April 2012

This is a project template I have put together for personal use in quick setup for web-application 
development.  I know a few people it might be useful to, so I am treating it like software and putting
it out there for all to see.  Very little of this project is anything I can personally lay claim to
however.  It is a combination of other libraries (see Credits section below), patterns borrowed from 
other templates/projects, and a small bit of my own innovation and approach.  

The readme contains the following main sections:

+ [Installation](#ins)
+ [System requirements](#req)
+ [How To Use](#how)
+ [Building](#bld)
+ [Credits](#crd)

<a name="ins"></a>Installation 
------------
This section documents installation instructions for Web Project Template.

1. Download (either fork, or just grab an archive DL)
2. Use at will

No, for reals.  There's not much use you're going to get out of this if you're not already
a web developer, don't already have some familiarity with the included JS libs, don't already 
have a familiarity with Less CSS, don't know how to use ant and don't make web-applications
of some sort.  If you fit that criteria, you'll probably have little trouble using it.

If you're adventurous and reasonably intelligent, you might use this project template as a
way to familiarize yourself with some of the included libs or the patterns being utilized.
Fair warning, this project isn't intended to be a tutorial though.

<a name="req"></a>System Requirements
-------------------
For easy setup/use of the project (particularly the builders), you'll probably need:
- Java (min version TBD)
- Perl (min version TBD)
- Ant (min version TBD)

If you don't have Ant, don't want to install Ant and don't want to deal with learning how to use it, 
you could probably grab [Eclipse](http://www.eclipse.org/) (be sure to get a version with Ant bundled).

If you're on Windows and thus, don't have Perl, your easiest bet is to just install 
[ActivePerl](http://www.activestate.com/activeperl).

If you're not on Windows, your built in Perl installation should work fine unless you're on
a really old version.

<a name="how"></a>How To Use
----------

TODO: include instructions for basic use, what first steps might be, etc.

Here's the breakdown of the major file locations (not 100% of them - some you might have to figure out
on your own.):

+ src/core/ 

> This is where the base of your system lives.  Your global css, your js libs, and so forth.

+ src/core/css/
+ src/core/css/@base.less 

> this is where all your less variable, mixin, and such coolness goes.  Why here? So that it's easy to import elsewhere.  You can use anything defined here in your global.less or /www/scripts/[app]/views files too.

+ src/core/css/@normalize.less
+ src/core/css/global.less 

> here's where you put your absolutely global css (really think about it before 
you put something here, remember - after 3-6 months and a few hundred files, you won't be able to take 
anything OUT of here without regressing EVERY SINGLE VIEW IN YOUR APPLICATION... so don't muck it up with
icky BS.)

+ src/core/css/print.less

> guess what this is for.  No really.  Guess.

+ src/core/js/@lib/

> this is where all your old-school javascript libraries live and all get built into one big
file housed at:
	/www/js/bin/core.js
(don't worry about including it, it's alreayd included via the /src/includes file)

+ src/core/js/helpers.handlebars
+ src/core/js/plugin.jquery 

> if you're adding more jquery plugins (or writing your own), they go here (I've included $.bbq 
'cause I like it and use it a lot. YMMV)

+ src/core/js/extend.js
+ src/core/js/log.js
+ src/core/config-log.js
+ src/core/config-require.js
+ src/dev
+ src/dev/config-less.js
+ src/img
+ src/includes
+ src/includes/includes.css.js
+ src/includes/includes.js.js
+ www/scripts/com.rc-designs
+ www/scripts/com.rc-designs/models
+ www/scripts/com.rc-designs/views
+ www/scripts/com.rc-designs/lib
+ www/scripts/com.rc-designs/pages
+ www/scripts/com.rc-designs/torso
+ www/scripts/com.rc-designs/utils
+ www/index.html


<a name="bld"></a>Building
---------------------------
You need Java, Perl, and Ant to build with this template.  Someday I might redo all of this 
to run exclusively in JS for use with node.js, but for now it's a smattering of things that 
are either already installed on your computer, or are easy to install.

Assuming you haven't made any significant changes and have your system requirements, you should
be able to run ant from the root of your project.  I.E. either command line into your project root
and type "ant" for a production build or "ant dev" to target the dev build (keep reading for the 
difference).

###Build Types:

+ Dev builds

> In a dev build your js (src/*) and css/less (src/*, and www/scripts/* ) files will be used directly 
> (via document writes) so you can live edit your files and see changes without having to run a build 
> every time you make a change. (Note: with this and all other of the build type files, if you add a 
> NEW file, you will always have to run a build unless that file is used exclusively through the JS 
> module pattern).

+ Production builds (default)

> In a production build, all your js/css|less files (as in the dev build) will be combined, minified 
> (optionally) and then a require.js build will be run, producing the www-release directory (upon 
> which the closure compiler will be run (optionally)).  

###Build Configuration:
If you need to modify the build(s) to suit your own purposes, the ant build files (and the location 
of their config files) are located:

+ /build.xml ( /build/* )
+ /src/build.xml ( /src/build/* )
+ /www/scripts/build.xml ( /www/scripts/build/* )

So, for example if you need/want to set some user specific values for your base build properties (like
a custom path for perl), and your system username is "fooman" you would drop in this file:
> /build/fooman.properties

For more details about building, check the incorporated build system documentation (either from the 
buildthekraken project or the require.js builder ).

<a name="crd"></a>Credits
-------
In no particular order, here's all the other projects that are making my work possible:

+ http://requirejs.org/
+ http://documentcloud.github.com/backbone/
+ http://asciidisco.github.com/Backbone.Mutators/index.html
+ http://documentcloud.github.com/underscore/
+ http://jquery.com/
+ http://benalman.com/projects/jquery-bbq-plugin/
+ http://handlebarsjs.com/
+ http://modernizr.com/
+ http://html5boilerplate.com/
+ http://lesscss.org/
+ http://github.com/necolas/normalize.css
+ http://ejohn.org/blog/simple-javascript-inheritance/
+ https://github.com/cpatik/console.log-wrapper
+ http://developer.yahoo.com/yui/compressor/
+ https://developers.google.com/closure/compiler/
+ https://bitbucket.org/webnesto/com.rc-designs.tools.buildthekraken (note: moving to github soon)
+ http://maqueapp.com/

I could go on to thank Apache, and other organizations/people like that, but I think you get the point.