require 'magpie-gem/property_space_type.rb'
require_relative 'concerns/use_types'

module Magpie
  class PropertySpaceTypeOffice < Magpie::PropertySpaceType
    attr_accessor :ceiling_height
    use_type :office

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
    use_type :retail

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
    use_type :industrial

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
    include UseTypes
    expose_use_types  :office,
                      :retail,
                      :industrial,
                      :land,
                      :multi_family,
                      :special_purpose,
                      class: PropertySpaceType, context: 'property', enforce_type: true

    def load_from_model(building)
      %w[office retail industrial].each do |use_type|
        public_send(use_type).load_from_model(building)
      end
      self
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json).slice(*self.class.use_types.map(&:to_s))
      self.set_attributes(obj, context)
      self
    end

    def model_attributes_base
      {
      }
    end
  end
end