module Magpie
  class PropertyAmenities < Magpie::Base
    attr_accessor :amenities
    def initialize
      self.amenities = HashWithIndifferentAccess.new
      self.amenities["Paid parking"] = Magpie::PropertyAmenityPaidParking.new
      self.amenities["Doors"] = Magpie::PropertyAmenityDoors.new
    end

    def load_from_model(building)
      self.amenities["Paid parking"].load_from_model(building)
      self.amenities["Sprinklers"] = building.sprinklers
      self.amenities["HVAC"] = building.hvac
      self.amenities["Elevators"] =  building.elevators
      self.amenities["Sewer"] = building.sewer
      self.amenities["Doors"].load_from_model(building)

      building.amenities.each{|a|
        @amenities[a.name] = true
      }

      self
    end

    def as_json(options)
      j = super.as_json(options)
      j.nil? ? nil : j['amenities']
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json)
      self.amenities = obj.deep_dup
      (self.amenities["Paid parking"] = Magpie::PropertyAmenityPaidParking.new).attributes = obj["Paid parking"] if obj["Paid parking"].is_a? Hash
      (self.amenities["Doors"] = Magpie::PropertyAmenityDoors.new).attributes = obj["Doors"] if obj["Doors"].is_a? Hash
      self
    end

    def model_attributes_base
      {
        sprinklers: @amenities["Sprinklers"],
        hvac: @amenities["HVAC"],
        elevators: @amenities["Elevators"],
        sewer: @amenities["Sewer"]
      }
    end

  end

  class PropertyAmenityPaidParking < Magpie::Base
    attr_accessor :ratio, :rate
    def load_from_model(building)
      @ratio = building.parking_ratio
      @rate = building.parking_rate
    end
  end

  class PropertyAmenityDoors < Magpie::Base
    attr_accessor :dock, :grade
    def load_from_model(building)
      @dock = building.dock_height
      @grade = building.grade_level
    end
  end
end