require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "http"
require 'uri'
require 'net/http'



# Set up API base URL and API key
API_BASE_URL = 'https://api.themoviedb.org/3'
API_KEY = ENV.fetch("THEMOVIEDB_KEY")

#begin
url = URI("https://api.themoviedb.org/3/search/movie?query=brother&include_adult=false&language=en-US&page=1")
#end

# Home route
get '/' do
  erb:index
end

# Search route
get '/search' do
  @query = params[:q]
  if @query
    @results = search_movies(@query)
  end
  erb :search
end

# Add movie to watchlist
post '/add_to_watchlist' do
  movie_id = params[:movie_id]
  title = params[:title]
  cookies[:watchlist] ||= {}
  cookies[:watchlist][movie_id] = title
  redirect back
end

# Remove movie from watchlist
post '/remove_from_watchlist' do
  movie_id = params[:movie_id]
  cookies[:watchlist].delete(movie_id)
  redirect back
end

# Mark movie as watched
post '/mark_as_watched' do
  movie_id = params[:movie_id]
  cookies[:watchlist][movie_id] += ' (watched)'
  redirect back
end

# Helper method to search movies using TMDb API
def search_movies(query)
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)

  response = HTTP.get("#{API_BASE_URL}/search/movie?&query=#{query}&include_adult=false&language=en-US&page=1")
  request["accept"] = 'application/json'
  request["Authorization"] = 'Bearer #{API_KEY}'
  if response.success?
    return JSON.parse(response.body)['results']
  else
    return []
  end
end
