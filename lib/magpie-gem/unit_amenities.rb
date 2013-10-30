module Magpie
  class UnitAmenities < Magpie::Base
    attr_accessor :amenities

    def initialize
      self.amenities = HashWithIndifferentAccess.new
      self.amenities['Doors'] = Magpie::UnitAmenityDoors.new
    end

    def load_from_model(space)
      self.amenities['Sprinklers'] = space.sprinklers
      self.amenities['Furnished'] = space.furnished
      self.amenities['Doors'].load_from_model(space)
      self
    end

    def as_json(options)
      j = super.as_json(options)
      j.nil? ? nil : j['amenities']
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

  class UnitAmenityDoors < Magpie::Base
    attr_accessor :dock, :grade
    ensure_number_precision(:dock, 0)
    ensure_number_precision(:grade, 0)

    def load_from_model(building)
      @dock = building.dock_height
      @grade = building.grade_level
    end
  end
end