require 'sucker_punch'
require 'sinatra'
require 'mongoid'
require 'sinatra/json'
require 'D:\UTM\2020\PAD\lab1\model\coffee.rb'
require 'json'
require 'D:\UTM\2020\PAD\lab1\jobs\deliver.rb'


Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

  get '/orders' do
    Coffee.all.to_json
  end

  get '/orders/:id' do
    order_id = params['id']
    order = Coffee.find(order_id)
    json(order)
  end

  post '/orders' do
    body = JSON.parse(request.body.read)
    coffee_order = Coffee.create(vegan:body["vegan"], type:body["type"], sugar_cubes:body["sugar_cubes"], status:"ordered")
    json(coffee_order)
  end

  put '/orders/:id' do
    order_id = params["id"]
    order = Coffee.find(order_id)
    order.status = "starting"
    order.save
      
    Deliver.perform_in(time_for_preparation(order.type),{id:order_id})

    json(order)
  end

  get '/status' do
    count = Coffee.all.to_a.count{|order|["ordered","starting"].include?(order.status)}
    json({count:count})
  end


  def time_for_preparation (coffe_type)
    if coffee_type = "americano" 
      return 15 
    elsif coffe_type = "espresso"
      return 3
    elsif coffe_type = "latte"
      return 7
    else return 40
    end
  end



  
 

  