require "sinatra"
require "sinatra/reloader"
require "sinatra/cookies"
require "http"
require 'uri'
require 'net/http'



# Set up API base URL and API key
API_BASE_URL = 'https://api.themoviedb.org/3'
API_TOKEN = ENV.fetch("THEMOVIEDB_TOKEN")

#begin
url = URI("https://api.themoviedb.org/3/search/movie?query=brother&include_adult=false&language=en-US&page=1")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["accept"] = 'application/json'
request["Authorization"] = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlODM1MTk3ZWQ3YWQyNzY0MDJmN2NkMWI1Y2E3MWY5ZCIsInN1YiI6IjY1ZmFmODkyMDQ3MzNmMDE0YWU1Y2RlNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.et0i1ZM0aai2TyLv9wtlDAS1bFSjXW_lfVYn-Wb-wzU'

response = http.request(request)
puts response.read_body
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
  response = HTTP.get("#{API_BASE_URL}/search/movie?api_key=#{API_KEY}&query=#{query}")
  if response.success?
    return JSON.parse(response.body)['results']
  else
    return []
  end
end
