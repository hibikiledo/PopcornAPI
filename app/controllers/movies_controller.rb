class MoviesController < ApplicationController

  def initialize
    @message = []
  end

  def create
    user = current_user
    if user
      movie = Movie.create(create_movie_params)
      if movie.valid?
        @error = false
      else
        @error = true
        @message.append(movie.errors.messages)
      end
    end
  end

  def info
    @movie = Movie.find_by(id: params[:mid])
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

    def create_movie_params
      params.require(:movie).permit(:title, :year, :genre, :plot)
    end

end
