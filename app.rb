require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "http"
require "json"

API_BASE_URL = "https://api.themoviedb.org/3"
api_key = ENV.fetch("THEMOVIEDB_KEY")

# Home route
get("/") do
  erb(:index)
end

# Search route
get("/search") do
  @query = params[:q]
  query_sub = params[:q].gsub(" ", "+")
  search_url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{query_sub}"
  raw_response = HTTP.get(search_url)
  parsed_response = JSON.parse(raw_response)
  @results = parsed_response["results"]
  erb(:search)
end


post("/add_to_watchlist") do
  movie_id = params[:movie_id]
  title = params[:title]
    
  # Deserialize the watchlist from JSON or initialize an empty Hash
  watchlist = JSON.parse(cookies['watchlist'] || '{}')
  
  # Add the new movie to the watchlist
  watchlist[movie_id] = title
  
  # Serialize the updated watchlist back to JSON and store in cookies
  cookies.store('watchlist', watchlist.to_json)
  
  redirect "/"
end

# Remove movie from watchlist
post("/remove_from_watchlist") do
  movie_id = params[:movie_id]
 
  # Deserialize the watchlist from JSON or initialize an empty Hash
  watchlist = JSON.parse(cookies['watchlist'] || '{}')

  # Remove the movie from the watchlist
  watchlist.delete(movie_id)

  # Serialize the updated watchlist back to JSON and store in cookies
  cookies.store('watchlist', watchlist.to_json)
  
  redirect back
end

# Mark movie as watched
post("/mark_as_watched") do
  movie_id = params[:movie_id]
  
  # Deserialize the watchlist from JSON or initialize an empty Hash
  watchlist = JSON.parse(cookies['watchlist'] || '{}')

  # Mark the movie as watched in the watchlist
  watchlist[movie_id] += ' (watched)'

  # Serialize the updated watchlist back to JSON and store in cookies
  cookies.store('watchlist', watchlist.to_json)

  redirect back
end

# Helper method to fetch poster URL from TMDb API
def fetch_poster_url(movie_id)
  url = "#{API_BASE_URL}/movie/#{movie_id}?api_key=#{API_KEY}"
  response = HTTP.get(url)
  parsed_response = JSON.parse(response.to_s)
  poster_path = parsed_response["poster_path"]
  poster_path ? "https://image.tmdb.org/t/p/w200#{poster_path}" : nil
end
