require 'rubygems'
require 'sinatra'

configure do
  [
		'pathname', 'yaml', 'json', 'haml', 'ostruct', 'sass', 
		'dm-core', 'dm-is-versioned', 'dm-timestamps', 'dm-validations', 
		'dm-aggregates', 'dm-tags', 'wikitext', 'jsmin', 'article', 'user'
	].each { |lib| require lib }


  ROOT = File.expand_path(File.dirname(__FILE__))
  config = begin
    YAML.load(File.read("#{ROOT}/config.yml").gsub(/ROOT/, ROOT))[Sinatra::Application.environment.to_s]
  rescue => ex
    raise "Cannot read the config.yml file at #{ROOT}/config.yml - #{ex.message}"
  end

  DataMapper.setup(:default, config['db_connection'])
	# DataMapper.auto_upgrade!

  PARSER = Wikitext::Parser.new({
		:external_link_class => 'external',
		:internal_link_prefix => nil, 
		:img_prefix => "/files/"
	})
	
	UPLOADS = File.join(ROOT, 'public/files')
	SITENAME = config['sitename']
	
	use Rack::Session::Cookie, :secret => 'b7c74f7fbde596ba87ac98ff4a9c8235d437ebce'
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
	
	def link_to(text, url)
		%{<a href="#{url}">#{text}</a>}
	end
	
	# Authentication Methods
	def login_required
	  if session[:user]
	    return true
	  else
	    session[:return_to] = request.fullpath
	    redirect '/login'
	    return false 
	  end
	end

	def current_user
	  User.first(session[:user])
	end

	def redirect_to_stored
	  if return_to = session[:return_to]
	    #session[:return_to] = nil
	    redirect return_to
	  else
	    redirect '/'
	  end
	end
end

# Load routes from other files
load File.join(ROOT, "routes/auth.rb")
load File.join(ROOT, "routes/upload.rb")
load File.join(ROOT, "routes/sass.rb")
load File.join(ROOT, "routes/js.rb")

get '/' do
  @article = Article.first_or_create(:slug => 'Index')
  @recent = Article.all(:order => [:updated_at.desc], :limit => 10)
	@user = User.first(:id => @article.user_id)
  erb :show, :layout => :article, :locals => {:action => ["Viewing", "View"]}
end

post '/' do
  @article = Article.first_or_create(:slug => params[:slug])
  unless params[:preview] == '1'
    @article.update_attributes(:title => params[:title], :body => params[:body], :slug => params[:slug])
    redirect "/#{params[:slug].gsub(/^index$/i, '')}"
  else
    haml :edit, :layout => :article, :locals => {:action => ["Editing", "Edit"]}
  end
end

get '/:slug' do
	case params[:slug]
		when "upload" then pass
		when "upload_form" then pass
		when "files" then pass
		# when "json-test" then pass
		when "users" then pass
	end
	
  @article = Article.first(:slug => params[:slug])
  if @article
    erb :show, :layout => :article, :locals => {:action => ["Viewing", "View"]}
  else
		login_required
    @article = Article.new(:slug => params[:slug], :title => de_wikify(params[:slug]))
    erb :edit, :layout => :article, :locals => {:action => ["Creating", "Create"]}
  end
end

get '/:slug/history' do
  @article = Article.first(:slug => params[:slug])
  erb :history, :layout => :article, :locals => {:action => ["History"]}
end

get '/:slug/edit' do
  @article = Article.first(:slug => params[:slug])
  erb :edit, :layout => :article, :locals => {:action => ["Editing", "Edit"]}
end

post '/:slug/edit' do
  @article = Article.first(:slug => params[:slug])
  @article.body = params[:body] if params[:body]
  haml :revert, :layout => :article, :locals => {:action => ["Reverting", "Revert"]}
end
