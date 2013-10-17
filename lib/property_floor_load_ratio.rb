class Magpie::PropertyFloorLoadRatio < Magpie::Base
  attr_accessor :single_tenent, :multi_tentent

  def load_from_model(building)
    @single_tenent = building.floor_load
    @multi_tentent = building.partial_floor_load

    self
  end

  def model_attributes_base
    {
      floor_load: @single_tenent,
      partial_floor_load: @multi_tentent
    }
  end
end