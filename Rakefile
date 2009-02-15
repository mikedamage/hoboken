require 'spec/rake/spectask'

task :environment do
  %w(dm-core dm-is-versioned dm-timestamps wikitext article).each { |lib| require lib }

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
			print "Pick a name for the root user: [admin] "
			username = $stdin.gets.chomp
			print "\nPassword: "
			pass = $stdin.gets.chomp
			print "\nConfirm Password: "
			pass_confirm = $stdin.gets.chomp
		else
		end
	end
end