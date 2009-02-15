class Article
  REP = '<+<<*>>+>'

  include DataMapper::Resource
	
	belongs_to :user
	has_tags
	
	# TODO: make "created_by" property
	# TODO: make an "editable by others" boolean
	
  property :id,               Serial
  property :body,             Text
  property :title,            String
  property :slug,             String
	property :user_id,					Integer						

  property :created_at,       DateTime
  property :updated_at,       DateTime

  is :versioned, :on => :updated_at

  def auto_link
    keeps = []
    # replace everything currently within brackets with our constant
    # and save the results
    altered = body.gsub(/\[+.*?\]+/) do |match|
      # save what we're replacing so we can put it back later
      keeps << match
      REP
    end
    # auto-link any articles
    altered.gsub!(Regexp.new("(#{Article.all.map{|x| x.slug}.join("|")})"), "[[\\1]]")
    # put our original already-bracketed items back
    altered.gsub!(REP){|match| keeps.shift}
    altered
  end
end