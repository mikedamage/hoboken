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
	desc 'migrate the article table'
	task :article => [:environment] do 
	  Article.auto_migrate!
	  Article.create(:slug => "Index", :title => "Index", :body => "Welcome to hoboken.  You can edit this content")
	end
	
	desc 'migrate the user table'
	task :user => [:environment] do
		User.auto_migrate!
		if User.count(:role => "admin") == 0
			puts "Creating admin user..."
			puts "Enter your email address: "
			email = $stdin.gets.chomp
			puts "Password: "
			pass = $stdin.gets.chomp
			puts "Confirm Password: "
			pass_confirm = $stdin.gets.chomp
			
			user = User.new(:email => email, :password => pass, :password_confirmation => pass_confirm)
			if user.save
				puts "User #{email} created!"
			else
				puts "Error creating user!"
			end
		end
	end
end