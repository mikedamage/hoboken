# Hoboken: Urban Renewal
Based on _Hoboken_ by Jeff Chupp,
Forked and spooned by Mike Green

## About
_Hoboken: Urban Renewal_ is my attempt to customize Hoboken wiki to fit my needs, much like the yuppies did with the real Hoboken, NJ in the late 1990's. Hoboken itself is a really awesome, very simple wiki by [Jeff Chupp](http://semanticart.com). This fork has added functionality that includes:

* file upload interface
* drag-n-drop embedding of links & images in articles
* [MarkItUp](http://markitup.jaysalvat.com/) wikitext editor
* templates in ERB instead of Haml _(just my personal preference)_
* user authentication _(incomplete)_
* support for tagging, thanks to dm-tags _(incomplete)_

## Required Gems
* dm-core
* dm-more
	* dm-is-versioned
	* dm-timestamps
	* dm-aggregates
	* dm-tags
	* dm-validations
* haml
* sinatra
* wikitext

dm-is-versioned, dm-aggregates, dm-tags and dm-timestamps are part of __dm-more__.  You'll need at least 0.9.7.  You also need a dm compatible database adapter (sqlite3, mysql, etc).

You can install wikitext from [http://github.com/stephenjudkins/ruby-wikitext/tree/master](http://github.com/stephenjudkins/ruby-wikitext/tree/master).

## How To:

First copy (or rename) <code>config.yml.template</code> to <code>config.yml</code> in the app root. If you want to use something besides the default datamapper connection string specified in the config you can change it as you wish. You should then run

	$ rake migrate:all

To create the database and your username and password. Now you're ready to run Sinatra's development server:

	$ ruby wiki.rb

then visit: <code>http://0.0.0.0:4567/</code> or visit <code>http://0.0.0.0:4567/Whatever</code> to start creating a page named "Whatever".

Standard WikiText applies as per the wikitext gem. Versioning is active, though complex diffs on versions aren't yet available and merging is still rudimentary.

When rendering a wiki page, items that exist in the database as other pages will be automatically linked to.

If you don't want just anybody to be able to register for a username and password (recommended), then comment out the signup action in @routes/auth.rb@. With that action disabled, the only way to create a new user is to use the included Rake task like so:

	$ rake user:new

and follow the prompts for the user's email address and password.

## NOTE:

if you get complaints along the lines of

    Gem::Exception: can't activate data_objects (= 0.9.7, runtime), already activated data_objects-0.9.9

then you should specify a version of data\_objects (in wiki.rb underneath "require 'sinatra'") like so

    gem 'data_objects', '0.9.7'

## TODO:
* diffs on versions