# Takes JS files from the public directory and minifies them using the JSMin Rubygem
get '/js/minify/:file' do
	content_type 'text/javascript', :charset => 'utf-8'
	@file = Pathname.new("./public/javascripts/" + params[:file])
	@mini = JSMin.minify(@file.read)
	@mini
end
