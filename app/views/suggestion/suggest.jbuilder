if @error
  json.error @error
  json.msg @message  
end

unless @error
  json.error @error
  json.suggestions @suggestions do |suggestion|
    json.movie_title  suggestion.movie.title
    json.rating       suggestion.stars
    json.genre        suggestion.movie.genre
    json.plot         suggestion.movie.plot
  end
end