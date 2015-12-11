require 'digest/sha2'

class UsersController < ApplicationController

  def initialize
    @message = []
  end

  # [POST]
  # Create new user
  #   params :email, :password, :token
  # /users/create
  def create
    @user = User.create(create_user_params)

    if @user.valid?
      token = Digest::SHA2.hexdigest(
        create_user_params[:email] + create_user_params[:password])

      @user.token = token
      @user.readable_id = create_user_params[:email].split("@")[0]
      @user.save

      @error = false
    else
      @error = true
      @message.append(@user.errors.messages)
    end
  end

  # [POST]
  # Login for token
  #   params :email, :password
  # /users/login
  def login
    @user = User.find_by(email: login_params[:email])
    @error = @user.nil?
    if @user
      @error = (@user.password != login_params[:password])
    end
  end

  # [GET] 
  # Returns user's display_name, profile_pic, email, id
  #   params :token (current_user)
  # /users/:token
  def info
    @user = current_user
  end 

  # [POST]
  # Update user's property specified via key :profile
  # /users/:token/update
  def update
    user = current_user
    user.update(update_user_params) if user
  end

  # [POST]
  # Upload new user profile image
  # /users/:token/upload
  def upload
    user = current_user
    # Get params from the request
    picture = upload_image_params
    # Convert Base64 to binary data
    picture_bin = Base64.decode64(picture[:base64])
    picture_name = picture[:fname]
    # Create a new file for saving image
    file_name = Time.new.to_s.gsub!(' ', '_') + '.jpg'    
    file_name_rpath = File.join('public', 'uploads', file_name)
    image_file = File.new(file_name_rpath, File::CREAT|File::TRUNC|File::RDWR, 0644)
    image_file.syswrite(picture_bin)
    image_file.close()
    # Update image file name to user object
    user.profile_pic = file_name
    user.save
    # Expose to response
    @pub_filename = file_name
  end

  # [POST]
  # Befriend with another user
  #   Params :token (current_user), :uid (another_user)
  # /users/:token/befriend/:uid
  def befriend
    user = current_user
    another_user = User.find_by(readable_id: params[:uid])
    # set error flag and message
    @error = user.nil? || another_user.nil?
    @message.append({uid: "Friend uid is invalid."}) if another_user.nil?
    # add to friend list of current_user
    unless user.friends.include?(another_user)
      user.friends.append(another_user) unless @error
      another_user.friends.append(user) unless @error
    end
  end

  # [POST]
  # Unfriend with another user
  #   Params :token (current_user), :uid (another_user)
  # /users/:token/befriend/:uid
  def unfriend
    user = current_user
    another_user = User.find_by(id: params[:uid])
    # set error flag and message
    @error = user.nil? || another_user.nil?
    @message.append({uid: "Friend uid is invalid."}) if another_user.nil?
    # add to friend list of current_user
    user.friends.delete(another_user) unless @error
    another_user.friends.delete(user) unless @error
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

    def update_user_params
      params.require(:profile).permit(:readable_id)
    end

    def create_user_params
      params.require(:account).permit(:email, :password)
    end

    def login_params
      params.require(:account).permit(:email, :password)
    end

    def upload_image_params
      params.require(:picture).permit(:fname, :base64)
    end

end
