class Movie < ActiveRecord::Base

  def to_s
    puts "[Movie] Title:: #{self.title} Year:: #{self.year}"
  end

end
