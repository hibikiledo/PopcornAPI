class Review < ActiveRecord::Base

  belongs_to :user
  belongs_to :movie  

  def to_s
    puts "[Review] Movie Title: #{self.movie.title} Reviewed By : #{self.user.email}"
  end

end
