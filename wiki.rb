require 'rubygems'
require 'sinatra'

configure do
  %w(pathname yaml haml sass dm-core dm-is-versioned dm-timestamps wikitext jsmin article).each { |lib| require lib }

  ROOT = File.expand_path(File.dirname(__FILE__))
  config = begin
    YAML.load(File.read("#{ROOT}/config.yml").gsub(/ROOT/, ROOT))[Sinatra::Application.environment.to_s]
  rescue => ex
    raise "Cannot read the config.yml file at #{ROOT}/config.yml - #{ex.message}"
  end

  DataMapper.setup(:default, config['db_connection'])

  PARSER = Wikitext::Parser.new(:external_link_class => 'external', :internal_link_prefix => nil)
end

helpers do
  # break up a CamelCased word into something more readable
  # this is used when you create a new page by visiting /NewItem
  def de_wikify(phrase)
    phrase.gsub(/(\w)([A-Z])/, "\\1 \\2")
  end

  def friendly_time(time)
    time.strftime("%a. %b. %d, %Y, %I:%M%p")
  end
end

get '/' do
  @article = Article.first_or_create(:slug => 'Index')
  @recent = Article.all(:order => [:updated_at.desc], :limit => 10)
  haml :show
end

post '/' do
  @article = Article.first_or_create(:slug => params[:slug])
  unless params[:preview] == '1'
    @article.update_attributes(:title => params[:title], :body => params[:body], :slug => params[:slug])
    redirect "/#{params[:slug].gsub(/^index$/i, '')}"
  else
    haml :edit, :locals => {:action => ["Editing", "Edit"]}
  end
end

get '/:slug' do
  @article = Article.first(:slug => params[:slug])
  if @article
    haml :show
  else
    @article = Article.new(:slug => params[:slug], :title => de_wikify(params[:slug]))
    haml :edit, :locals => {:action => ["Creating", "Create"]}
  end
end

get '/:slug/history' do
  @article = Article.first(:slug => params[:slug])
  haml :history
end

get '/:slug/edit' do
  @article = Article.first(:slug => params[:slug])
  haml :edit, :locals => {:action => ["Editing", "Edit"]}
end

post '/:slug/edit' do
  @article = Article.first(:slug => params[:slug])
  @article.body = params[:body] if params[:body]
  haml :revert
end

get '/upload' do
end

post '/upload' do
	
end

# Renders Sass stylesheets in the specified format.
# Valid formats are: extended, expanded, compact, compressed
get "/sass/:format/:file" do
	content_type 'text/css', :charset => 'utf-8'
	if params[:file] =~ /\.sass$/
		@file = Pathname.new("./views/sass/" + params[:file])
	else
		@file = Pathname.new("./views/sass/" + (params[:file] + ".sass"))
	end
	
	if @file.exist?
		@format = params[:format].intern
		@sass = Sass::Engine.new(@file.read, {:style => @format})
		@sass.render
	else
		raise not_found, "Sass stylesheet not found."
	end
end


# Takes JS files from the public directory and minifies them using the JSMin Rubygem
get '/js/minify/:file' do
	content_type 'text/javascript', :charset => 'utf-8'
	@file = Pathname.new("./public/javascripts/" + params[:file])
	@mini = JSMin.minify(@file.read)
	@mini
end
