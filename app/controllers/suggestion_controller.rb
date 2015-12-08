class SuggestionController < ApplicationController

  def initialize
    message = []
  end

  def suggest
    @user = current_user
    if @user
      @suggestions = @user.suggestions
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

end
