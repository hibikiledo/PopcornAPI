ComputeJob = Struct.new(:user) do

  def perform
    build_resource_file(user)
    compute()
  end


  private
    def build_resource_file(user)
      # get friends for this 'user'
      friends = user.friends

      # create resource file
      res_file = File.new("resources/resource_#{user.email}.csv", "w")

      # keys for all users
      user_keys = [user]
      friends.each do |friend|
        user_keys.append(friend)
      end    

      # keys for movies union together
      movie_keys = []

      # union all reviews from every friends and the user itself
      review_union = user.reviews
      friends.each do |f|
        review_union = review_union.union(f.reviews).group(:movie_id)
      end

      # build up keys for movies
      review_union.each do |review|
        movie_keys.append(review.movie.title)
      end

      puts "-------------- REVIEW UNION -----------------"
      puts review_union
      puts "---------------- USER KEYS ------------------"
      puts user_keys
      puts "---------------- MOVIE KEYS -----------------"
      puts movie_keys
      puts "----------------- MERGING -------------------"

      # write header to a csv file
      res_file.write('movie')
      res_file.write(',')   
      user_keys.each_with_index do |user, i|
        res_file.write(user.email)
        res_file.write(',') unless user_keys.count-1 == i
      end

      # for each movie write a row for it
      movie_keys.each_with_index do |movie, i|

        res_file.write("\n")
        res_file.write(movie)
        res_file.write(',')

        user_keys.each_with_index do |user, j|

          user_obj = User.find_by(email: user.email)
          movie_obj = Movie.find_by(title: movie)

          puts "-------------- Retrieve Objects --------------"

          puts user_obj       
          puts movie_obj

          puts "----------------------------------------------"

          specific_review = Review.find_by(user: user_obj, movie: movie_obj)
          puts specific_review

          puts "--------------------- END --------------------"        

          if specific_review
            res_file.write(specific_review.stars)
          end

          res_file.write(',') unless user_keys.count-1 == j
        end
      end    
      # close the file
      res_file.close()
    end

    def compute
      # generate paths
      python_script_path = Rails.root.join("lib/popcornRecommder.py")
      resource_file_path = Rails.root.join("resources/resource_#{user.email}.csv")
      result_file_path = Rails.root.join("outputs/output_#{user.email}.csv")

      exec_string = "python #{python_script_path} #{user.email} #{resource_file_path} #{result_file_path}"
      puts "Executing: #{exec_string}"

      # run the python script
      system(exec_string)

    end

end
