require 'rubygems'
require 'sinatra'

set :environment, :production
set :views, File.join(File.expand_path(File.dirname(__FILE__)), 'views')
disable :run

require 'wiki'

run Sinatra.application