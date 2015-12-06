unless @error
  json.error @error
  json.profile do
    json.id             @user.readable_id
    json.profile_pic    @user.profile_pic 
    json.email          @user.email
    
    json.friends        @user.friends do |friend|
      json.id           friend.id
      json.profile_pic  friend.profile_pic
      json.email        friend.email
    end

  end
end

if @error
  json.error @error
  json.msg @message
end