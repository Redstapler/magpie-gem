require 'magpie-gem/property_space_type.rb'

module Magpie
  class PropertySpaceTypeOffice < Magpie::PropertySpaceType
    attr_accessor :ceiling_height

    def load_from_model(building)
      self.total = building.office_rsf
      self.ceiling_height = building.ceiling_height
      self.specific_rate = building.office_rate
      super(building)
    end

    def model_attributes_base
      {
        office_rsf: @total,
        ceiling_height: @ceiling_height,
        office_rate: @specific_rate
      }
    end
  end

  class PropertySpaceTypeRetail < Magpie::PropertySpaceType
    def load_from_model(building)
      self.total = building.retail_rsf
      self.specific_rate = building.office_rate
      super(building)
    end

    def model_attributes_base
      {
        retail_rsf: @total,
        office_rate: @specific_rate
      }
    end
  end

  class PropertySpaceTypeIndustrial < Magpie::PropertySpaceType
    def load_from_model(building)
      self.total = building.industrial_rsf
      self.specific_rate = building.warehouse_rate
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

    def initialize
      self.office = Magpie::PropertySpaceTypeOffice.new
      self.retail = Magpie::PropertySpaceTypeRetail.new
      self.industrial = Magpie::PropertySpaceTypeIndustrial.new
    end

    def load_from_model(building)
      self.office.load_from_model(building)
      self.retail.load_from_model(building)
      self.industrial.load_from_model(building)

      self
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json).slice("office", "retail", "industrial")
      self.set_attributes(obj, context)
      self
    end

    def model_attributes_base
      {
      }
    end
  end
end