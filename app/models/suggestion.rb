class Suggestion < ActiveRecord::Base

  belongs_to :user
  belongs_to :movie

  validates :movie, uniqueness: {scope: :user}

  def to_s
    puts "[Suggestion] To User: #{self.user.email} Movie: #{self.movie.title} Stars: #{self.stars}"
  end

end
