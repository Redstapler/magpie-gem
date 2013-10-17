class Magpie::UnitAmenities < Magpie::Base
  attr_accessor :amenities

  def load_from_model(space)
    @amenities = HashWithIndifferentAccess.new({
      Sprinklers: space.sprinklers,
      Furnished: space.furnished,
      Doors: Magpie::UnitAmenityDoors.new.load_from_model(space)
    })
    self
  end

  def as_json(options)
    super.as_json(options)['amenities']
  end

  def from_json(json, context=nil)
    obj = JSON.parse(json)
    self.amenities = obj
    self.amenities["Doors"] = Magpie::UnitAmenityDoors.new.set_attributes(self.amenities["Doors"], context) if self.amenities["Doors"].present?
    self
  end

  def model_attributes_base
    {
      sprinklers: @amenities["Sprinklers"],
      furnished: @amenities["Furnished"]
    }
  end

end

class Magpie::UnitAmenityDoors < Magpie::Base
  attr_accessor :dock, :grade
  def load_from_model(building)
    @dock = building.dock_height
    @grade = building.grade_level
  end
end