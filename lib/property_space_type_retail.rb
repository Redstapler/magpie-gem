class Magpie::PropertySpaceTypeRetail < Magpie::PropertySpaceType
  def load_from_model(building)
    @total = building.retail_rsf
    @specific_rate = building.office_rate
    super(building)
  end

  def model_attributes_base
    {
      industrial_rsf: @total,
      office_rate: @specific_rate
    }
  end

end