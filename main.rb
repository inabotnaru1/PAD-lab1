require 'sucker_punch'
require 'sinatra'
require 'mongoid'
require 'sinatra/json'
require 'D:\UTM\2020\PAD\lab1\model\coffee.rb'
require 'json'
require 'D:\UTM\2020\PAD\lab1\jobs\deliver.rb'
require 'rest-client'
require 'securerandom'


set :port, 8000

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

GATEWAY_ADRESS = "http://127.0.0.1:8500/v1/agent/service/"

service_id = SecureRandom.hex

begin
at_exit do
  RestClient::Request.execute(
  method: :put,
  url: GATEWAY_ADRESS + "deregister/" + service_id)
end
rescue
  puts "handle"
ensure
  puts "bye"
end

begin
RestClient::Request.execute(
  method: :post,
  url: GATEWAY_ADRESS + "register?replace-existing-checks=true",
  payload: {"ID": service_id, "Name": "pad-orders-service","Address": "127.0.0.1","Port": 8000}.to_json
)
rescue
  puts "handle it"
ensure 
  puts "bye"
end


LIMIT = 8 #task limit

  get '/orders' do
    Coffee.all.to_json
  end

  get '/orders/:id' do #gets a specific order 
    order_id = params['id']
    order = Coffee.find(order_id)
    json(order)
  end

  post '/orders' do #create a new order based on request, if the task limit isn't reached
    if !can_create_order 
      halt 400, json({error:"Task limit reached"})
    end
    body = JSON.parse(request.body.read)
    coffee_order = Coffee.create(vegan:body["vegan"], type:body["type"], sugar_cubes:body["sugar_cubes"], status:"ordered")
    json(coffee_order)
  end

  put '/orders/:id' do #the order is started and based on coffee type the time for preparation is calculated
    order_id = params["id"]
    order = Coffee.find(order_id)
    order.status = "starting"
    order.save
    
    Deliver.perform_in(time_for_preparation(order.type),{id:order_id})
    json(order)
  end

  get '/status' do #gets all teh orders that are being processed
    count = Coffee.all.to_a.count{|order|["ordered","starting"].include?(order.status)}
    json({count:count})
  end


  def time_for_preparation (coffe_type)
    if coffee_type == "americano" 
      return 15 
    elsif coffe_type == "espresso"
      return 3
    elsif coffe_type == "latte"
      return 7
    else return 40
    end
  end

  def can_create_order
    count = Coffee.all.to_a.count{|order|["ordered","starting"].include?(order.status)}
    count < LIMIT
  end



  
 

  