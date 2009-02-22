require 'spec/rake/spectask'

task :environment do
  %w(dm-core dm-is-versioned dm-aggregates dm-timestamps dm-tags dm-validations wikitext article user).each { |lib| require lib }

  ROOT = File.expand_path(File.dirname(__FILE__))
  config = begin
    YAML.load(File.read("#{ROOT}/config.yml").gsub(/ROOT/, ROOT))['development']
  rescue => ex
    raise "Cannot read the config.yml file at #{ROOT}/config.yml - #{ex.message}"
  end

  DataMapper.setup(:default, config['db_connection'])
end

desc "Run all specs"
task :spec do
  puts `ruby hoboken_spec.rb`
end

namespace :migrate do
	desc "migrate articles and users tables"
	task :all => [:environment, :automigrate, :article, :user]
	
	desc 'create user, article, versions, and tags tables'
	task :automigrate => [:environment] do
		DataMapper.auto_migrate!
	end
	
	desc 'add a first article to Articles table'
	task :article => [:environment] do 
	  Article.create(:slug => "Index", :title => "Index", :body => "Welcome to hoboken.  You can edit this content", :user_id => "1")
	end
	
	desc 'create admin user'
	task :user => [:environment] do
		if User.count(:role => "admin") == 0
			puts "Creating admin user..."
			puts "Enter your email address: "
			email = $stdin.gets.chomp
			puts "Password: "
			pass = $stdin.gets.chomp
			puts "Confirm Password: "
			pass_confirm = $stdin.gets.chomp
			
			user = User.new(:email => email, :password => pass, :password_confirmation => pass_confirm, :role => "admin")
			if user.save
				puts "User #{email} created!"
			else
				puts "Error creating user!"
			end
		end
	end
end

namespace :user do
	desc "create a new wiki user"
	task :new => [:environment] do
		$stdout.puts "Creating a new wiki user..."
		$stdout.puts "Enter email address: "
		email = $stdin.gets.chomp
		$stdout.puts "Enter password: "
		pass = $stdin.gets.chomp
		$stdout.puts "Confirm password: "
		confirm_pass = $stdin.gets.chomp
		$stdout.puts "Desired role:"
		$stdout.puts "[1] admin"
		$stdout.puts "[2] user"
		role = case $stdin.gets
		when "1" then "admin"
		when "2" then "user"
		else "user"
		end
		
		user = User.new(:email => email, :password => pass, :password_confirmation => confirm_pass, :role => role)
		if user.save
			puts "User #{email} created!"
		else
			puts "Error creating user!"
		end
	end
end