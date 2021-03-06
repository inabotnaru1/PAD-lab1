require 'sucker_punch'
require 'sinatra'
# require 'mongoid'
require 'sinatra/json'
# require_relative 'model\coffee.rb'
require 'json'
# require_relative 'jobs\deliver.rb'
require 'rest-client'
require 'securerandom'
require 'mongoid'

set :bind, '0.0.0.0'
set :port, 8000

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

GATEWAY_ADRESS = "http://consul:8500/v1/agent/service/"

SERVICE_ID = SecureRandom.hex

TASK_LIMIT = 8 

begin
at_exit do
  RestClient.put GATEWAY_ADRESS + "deregister/" + SERVICE_ID, {}.to_json
end
rescue
  puts "Error when exit"
ensure
  puts " "
end

begin
RestClient.put GATEWAY_ADRESS + "register?replace-existing-checks=true", {"ID": SERVICE_ID, "Name": "orders-service","Address": "orders-service","Port": 8000}.to_json
rescue
  puts "Connection to the gateway failed"
ensure 
  puts " "
end


  get '/' do
    respone =  RestClient.put GATEWAY_ADRESS + "register?replace-existing-checks=true", {"ID": SERVICE_ID, "Name": "orders-service","Address": "orders-service","Port": 8000}.to_json
    json(respone)
  end

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
    else
    body = JSON.parse(request.body.read)
    coffee_order = Coffee.create(vegan:body["vegan"], type:body["type"], sugar_cubes:body["sugar_cubes"], status:"ordered")
    json(coffee_order)
    end
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
    count < TASK_LIMIT
  end


  class Deliver
    include SuckerPunch::Job
    workers 10
  
    def perform(params)
        order = Coffee.find(params[:id])
        puts order.status
        order.status = "done"
        order.save
    end
  end

  class Coffee
    include Mongoid::Document

    field :vegan, type: Boolean
    field :type, type: String 
    field :sugar_cubes, type: Integer
    field :status, type: String

  end
  
 

  