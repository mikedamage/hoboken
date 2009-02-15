get '/users/logged_in' do
	if request.xhr?
		content_type "text/json", :charset => "utf-8"
		if session[:user]
			@user = User.find(:id => session[:user])
			{:user => {:id => session[:user], :name => @user.email, :role => @user.role}}.to_json
		else
			{:user => nil}.to_json
		end
	else
		if session[:user]
			"true"
		else
			"false"
		end
	end
end

get '/users/login' do
  erb :login
end

post '/users/login' do
	if user = User.authenticate(params[:email], params[:password])
		session[:user] = user.id
		redirect_to_stored
	else
		redirect '/login'
	end
end

get '/users/logout' do
	session[:user] = nil
	@message = "in case it weren't obvious, you've logged out"
	redirect '/'
end

get '/users/new' do
  erb :new_user
end

post '/users/new' do
  @user = User.new(:email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])
  if @user.save
    session[:user] = @user.id
    redirect '/'
  else
    session[:flash] = "failure!"
    redirect '/'
  end
end

get '/users/:id' do
	@user = User.first(params[:id])
	if session[:user] && @user.id == session[:user]
		erb :edit_user
	else
		erb :user
	end
end

post '/users/:id' do
	login_required
	@user = User.first(params[:id])
	# TODO: @user.update_attributes statement using params[]
end

delete '/users/:id' do
  user = User.first(params[:id])
  user.delete
  session[:flash] = "way to go, you deleted a user"
  redirect '/'
end

# Authentication Methods
private

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
    session[:return_to] = nil
    redirect return_to
  else
    redirect '/'
  end
end