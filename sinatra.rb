require 'sinatra'
require 'coffee-script'
require 'sass'

#
#def send_filtered(path)
#  file = File.open(path, "rb")
#  contents = file.read
#  send_data file
#end

get '/' do
  redirect '/popup.html'
end

get '/css/vendor/:file.js' do |file|
  send_file :'public/#{file}'
end

get '/js/vendor/:file.js' do |file|
  send_file :'public/#{file}'
end

get '/js/:file.js' do
  coffee :"coffee/#{params[:file]}"
end

get '/css/:file.css' do
  scss :"sass/#{params[:file]}"
end

options '/api/v1/messages' do
  headers "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Headers" => "Origin, Content-Type, Accept",
            "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
            "Content-Type" => "text/plain"
  body ""
  puts ">> OPTIONS"
end

post '/api/v1/messages' do
  headers "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Headers" => "Origin, Content-Type, Accept",
            "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
            "Content-Type" => "application/json"
  data = request.body.read
  body "null"
  puts ">> POST #{data}"
  nil
end

