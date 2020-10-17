require 'mongoid'

class Coffee
    include Mongoid::Document


    field :vegan, type: Boolean
    field :type, type: String  #capucino, americano
    field :sugar_cubes, type: Integer
    field :status, type: String

  end

  # {
  #   vegan: "true"
  #   type: "capucino"
  #   sugar_cubes: "2"
  #   status: "ordering"
  # }
