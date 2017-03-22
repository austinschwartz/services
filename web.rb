require 'redis'
require 'sinatra'
require 'json'
require 'socket'

redis = Redis.new(:host => "localhost", :port => 6379, :db => 0)

helpers do
  def get_data redis
    m = JSON.parse(redis.get("services"))
    m.map{|k, v| [k, v.chomp('"').reverse.chomp('"').reverse]}
     .sort{|x1, x2| x1[0] <=> x2[0]}
  end
end

set :port, 4433
set :bind, '0.0.0.0'


get '/' do
  content_type 'text/html'
  data = get_data(redis)
  str = """
  <head>
  <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'>
  </head>
  <body>
    <div class='container' style='width: 500px;'>
    <table class='table'>
      <tr>
        <th>Port</th>
        <th>Service</th>
      </tr>
  """
  data.each do |port, service|
    str += """
    <tr>
      <td><a href='http://austinschwartz.com:#{port}'>#{port}</a></td>
      <td>#{service}</td>
    </tr>
    """
  end
  str += """
    </table>
    </div>
  </body>
  """
  str
end

get '/api' do
  content_type 'application/json'
  redis.get("services")
end

get '/register' do
  port = params[:port]
  name = params[:name]
  json = redis.get("services")
  puts json
  hash = JSON.parse(json)
  hash[port] = name
  redis.set("services", JSON.dump(hash))
end


