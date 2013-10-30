require 'magpie-gem/property_space_types.rb'
require 'magpie-gem/property_lcs.rb'

module Magpie
  class PropertySpace < Magpie::Base
    has_one :types, :class => Magpie::PropertySpaceTypes, :context => 'property'

    attr_accessor :typical_floor_size, :largest_contiguous_space, :types
    
    def initialize
      self.types = Magpie::PropertySpaceTypes.new
      self.largest_contiguous_space = Magpie::PropertyLcs.new
    end

    def load_from_model(building)
      self.typical_floor_size = building.typical_floor_size
      self.largest_contiguous_space.load_from_model(building)
      self.types.load_from_model(building)

      self
    end

    def model_attributes_base
      {
        typical_floor_size: @typical_floor_size
      }
    end
  end
end