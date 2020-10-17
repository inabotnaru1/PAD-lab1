require 'sinatra'
require 'mongoid'
require 'D:\UTM\2020\PAD\lab1\model\user.rb'

Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

  get '/user' do
    User.all.to_json
  end

  post '/user' do
    User.create(name:'Ina', age:'12')
  end




  
 

  