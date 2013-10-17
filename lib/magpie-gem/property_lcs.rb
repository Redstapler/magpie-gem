module Magpie
  class PropertyLcs < Magpie::Base
    attr_accessor :size, :floor

    def load_from_model(building)
      @size = building.lcs_size
      @floor = building.lcs_floor_number

      self
    end

    def model_attributes_base
      {
        lcs_size: @size,
        lcs_floor_number: @floor
      }
    end
  end
end