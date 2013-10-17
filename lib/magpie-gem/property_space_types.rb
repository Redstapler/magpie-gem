require 'magpie-gem/property_space_type.rb'

module Magpie
  class PropertySpaceTypeOffice < Magpie::PropertySpaceType
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

  class PropertySpaceTypeRetail < Magpie::PropertySpaceType
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

  class PropertySpaceTypeIndustrial < Magpie::PropertySpaceType
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

  class PropertySpaceTypes < Magpie::Base
    has_one :office, :class => Magpie::PropertySpaceTypeOffice, :context => 'property'
    has_one :retail, :class => Magpie::PropertySpaceTypeRetail, :context => 'property'
    has_one :industrial, :class => Magpie::PropertySpaceTypeIndustrial, :context => 'property'
    attr_accessor :office, :retail, :industrial

    def load_from_model(space)
      @office = Magpie::PropertySpaceTypeOffice.new.load_from_model(space)
      @retail = Magpie::PropertySpaceTypeRetail.new.load_from_model(space)
      @industrial = Magpie::PropertySpaceTypeIndustrial.new.load_from_model(space)

      self
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json).slice(:office, :retail, :industrial)
      self.set_attributes(obj, context)
      self
    end

    def model_attributes_base
      {
      }
    end
  end
end