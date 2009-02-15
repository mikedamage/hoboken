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
