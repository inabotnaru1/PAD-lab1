require 'sinatra'
require 'mongoid'
require 'sinatra/json'
require 'D:\UTM\2020\PAD\lab1\model\coffee.rb'
require 'json'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

  get '/orders' do
    json({data: 'Hello world'})
    # Coffee.all.to_json
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
    json(order)
  end


  def time_for_preparation (coffe_type)
    if coffee_type = "americano" 
      return 5 
    elsif coffe_type = "espresso"
      return 3
    elsif coffe_type = "latte"
      return 7
    else return 6
    end
  end



  
 

  