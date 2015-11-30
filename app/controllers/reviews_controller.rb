require "compute_job"

class ReviewsController < ApplicationController

  def initialize
    @message = []
  end

  def create
    # Get current user
    @user = current_user
    @movie = Movie.find_by(id: create_review_params[:movie_id])
    
    # Only process if both user and movie is not nil    
    if @user && @movie      
      # Add required keys into params
      create_params = create_review_params
      create_params[:movie_id] = @movie.id
      create_params[:user_id] = @user.id

      @review = Review.create(create_params)

      @error = ! @review.valid?
      @message.append(@review.errors.messages) if @error   

      unless @error
        # update current user table
        #@review.delay.propagate_table(@user)
        Delayed::Job.enqueue ComputeJob.new(@user)

        @user.friends.each do |friend|
          Delayed::Job.enqueue ComputeJob.new(friend)
        end
      end
    end
  end

  private
    def current_user
      @user = User.find_by(token: params[:token])  
      # validate token and set proper error message  
      @error = @user.nil?
      @message.append({token: "Token is in valid"}) if @error
      # return user event if it's nil
      @user
    end

    def create_review_params
      params.require(:review).permit(:movie_id, :comment, :stars)
    end    

end
