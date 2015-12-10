require "net/http"
require "uri"

ComputeJob = Struct.new(:user) do

  def perform
    build_resource_file(user)
    compute()
    clear_suggestions(user)
    update_suggestions(user)
    send_push_notification(user.readable_id)
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
        movie_keys.append(review.movie)
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
        res_file.write(movie.id)
        res_file.write(',')

        user_keys.each_with_index do |user, j|

          puts "-------------------- REVIEW ------------------"

          specific_review = Review.find_by(user: user, movie: movie)
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

    def clear_suggestions(user)
      user.suggestions.destroy_all
    end

    def update_suggestions(user)
      # generate result file path
      result_file_path = Rails.root.join("outputs/output_#{user.email}.csv")
      # read output file contents
      result_file = File.open(result_file_path, 'r')
      lines = result_file.readlines
      # iterate through all suggestions
      lines.each do |line|
        movie_id, stars = line.split(',')
        # create params
        suggestion_params = {
          user_id: user.id,
          movie_id: movie_id,
          stars: stars
        }
        # add suggestion into database
        suggestion = Suggestion.create(suggestion_params)
        puts suggestion if suggestion
      end

    end

    def send_push_notification(readable_id)
      puts "[Notification] Sending request to GCM"

      uri = URI.parse("https://gcm-http.googleapis.com")

      request_data = {
        "to" => "/topics/#{readable_id}",
        "data" => {
          "message" => "New recommendation!"
        }
      }

      headers = {
        'Content-Type' => 'application/json', 
        'Authorization' => 'key=AIzaSyCeYOqajJPmxm7qhUvBx-1VPcZFTIpbLec'
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.post("/gcm/send", request_data.to_json, headers)

      puts "Response: #{response.body}"

    end

end
