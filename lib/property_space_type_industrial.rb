class Magpie::PropertySpaceTypeIndustrial < Magpie::PropertySpaceType
  def load_from_model(building)
    @total = building.industrial_rsf
    @specific_rate = building.warehouse_rate
    super(building)
  end

  def model_attributes_base
    {
      industrial_rsf: @total,
      warehouse_rate: @specific_rate
    }
  end

end