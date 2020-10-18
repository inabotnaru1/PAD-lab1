require 'mongoid'

class Coffee
    include Mongoid::Document

    field :vegan, type: Boolean
    field :type, type: String 
    field :sugar_cubes, type: Integer
    field :status, type: String

  end

 