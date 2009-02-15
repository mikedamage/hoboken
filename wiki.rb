require 'rubygems'
require 'sinatra'

configure do
  [	'pathname', 'yaml', 'json', 'haml', 'ostruct', 'sass', 
		'dm-core', 'dm-is-versioned', 'dm-timestamps', 'dm-validations',
		'wikitext', 'jsmin', 'article', 'user'
	].each { |lib| require lib }


  ROOT = File.expand_path(File.dirname(__FILE__))
  config = begin
    YAML.load(File.read("#{ROOT}/config.yml").gsub(/ROOT/, ROOT))[Sinatra::Application.environment.to_s]
  rescue => ex
    raise "Cannot read the config.yml file at #{ROOT}/config.yml - #{ex.message}"
  end

  DataMapper.setup(:default, config['db_connection'])

  PARSER = Wikitext::Parser.new(:external_link_class => 'external', :internal_link_prefix => nil, :img_prefix => "/files/")
	
	UPLOADS = File.join(ROOT, 'public/files')
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

	def javascript(*args)
		args.each do |script|
			"<script type=\"text/javascript\" src=\"#{script}\" charset=\"utf-8\"></script>"
		end
	end
end

get '/' do
  @article = Article.first_or_create(:slug => 'Index')
  @recent = Article.all(:order => [:updated_at.desc], :limit => 10)
  haml :show, :locals => {:action => ["Viewing", "View"]}
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
	case params[:slug]
		when "upload" then pass
		when "upload_form" then pass
		when "files" then pass
		when "json-test" then pass
	end
	
  @article = Article.first(:slug => params[:slug])
  if @article
    haml :show, :locals => {:action => ["Viewing", "View"]}
  else
    @article = Article.new(:slug => params[:slug], :title => de_wikify(params[:slug]))
    haml :edit, :locals => {:action => ["Creating", "Create"]}
  end
end

get '/:slug/history' do
  @article = Article.first(:slug => params[:slug])
  haml :history, :locals => {:action => ["History"]}
end

get '/:slug/edit' do
  @article = Article.first(:slug => params[:slug])
  haml :edit, :locals => {:action => ["Editing", "Edit"]}
end

post '/:slug/edit' do
  @article = Article.first(:slug => params[:slug])
  @article.body = params[:body] if params[:body]
  haml :revert, :locals => {:action => ["Reverting", "Revert"]}
end

get '/files' do
	@article = OpenStruct.new({ :title => "File Manager" })
	dir_children = Pathname.new(File.join(ROOT, 'public/files')).children
	@files = []
	dir_children.each do |file|
		file_class = case file.extname.delete(".")
		when "bmp" then "image_file"
		when "gif" then "image_file"
		when "jpg" then "image_file"
		when "png" then "image_file"
		when "pdf" then "pdf_file"
		else "other_file"
		end
		@files << {:name => file.basename.to_s, :size => (file.size/1000.0).to_s + "KB", :ext => file.extname.delete("."), :class => file_class}
	end
	unless request.xhr?
		haml :files
	else
		content_type "text/json", :charset => "utf-8"
		{"files" => @files}.to_json
	end
end

get '/json-test' do
	content_type "text/json", :charset => "utf-8"
	{"testkey" => "jambalaya"}.to_json
end

get '/upload' do
	@article = OpenStruct.new({ :title => "Upload a File" })
	haml :upload, :locals => {:action => ["Uploading", "Upload"]}
end

get '/upload_form' do
	@article = OpenStruct.new({:title => "Upload Form"})
	haml :upload_form, :layout => false
end

post '/upload' do
	content_type 'text/html', :charset => "utf-8"
	@upload = params[:data]
	@file = File.join(UPLOADS, @upload[:filename])
	@resp = Hash.new
	if File.open(@file, "w") {|f| f.write(@upload[:tempfile].read) }
		builder do |xml|
			xml.strong "Upload Complete"
			xml.ul do
				xml.li @upload[:filename]
				xml.li((File.size(@file) / 1000.0).to_s + " Kilobytes")
			end
			xml.p "You can now add a link to this file or embed it (if it's an image) using this url: /files/#{@upload[:filename]}"
			xml.a("Upload another file", "href" => "/upload_form", "target" => "upload_frame")
		end
	else
		builder do |xml|
			xml.strong "Error Uploading File"
			xml.p do
				xml.a("Try Again", "href" => "/upload_form", "target" => "upload_frame")
			end
		end
	end
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
