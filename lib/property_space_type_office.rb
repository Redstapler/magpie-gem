class Magpie::PropertySpaceTypeOffice < Magpie::PropertySpaceType
  attr_accessor :ceiling_height

  def load_from_model(building)
    @total = building.office_rsf
    @ceiling_height = building.ceiling_height
    @specific_rate = building.office_rate
    super(building)
  end

  def model_attributes_base
    {
      industrial_rsf: @total,
      ceiling_height: @ceiling_height,
      office_rate: @specific_rate
    }
  end

end