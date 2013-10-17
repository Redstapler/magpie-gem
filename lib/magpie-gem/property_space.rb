module Magpie
  class PropertySpace < Magpie::Base
    has_one :types, :class => Magpie::PropertySpaceTypes, :context => 'property'

    attr_accessor :typical_floor_size, :largest_contiguous_space, :types

    def load_from_model(building)
      @typical_floor_size = building.typical_floor_size
      @largest_contiguous_space = Magpie::PropertyLcs.new.load_from_model(building)
      @types = Magpie::PropertySpaceTypes.new.load_from_model(building)

      self
    end

    def model_attributes_base
      {
        typical_floor_size: @typical_floor_size
      }
    end
  end
end