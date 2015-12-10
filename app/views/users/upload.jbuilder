json.error @error
json.message @message if @error

unless @error
  json.error @error
  json.profile_pic @pub_filename
end