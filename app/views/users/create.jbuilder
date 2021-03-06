if @error
  json.error @error
  json.msg @message if @error
end

unless @error
  json.error @error
  json.profile do
    json.id             @user.readable_id
    json.profile_pic    @user.profile_pic 
    json.email          @user.email
    json.token          @user.token
  end
end