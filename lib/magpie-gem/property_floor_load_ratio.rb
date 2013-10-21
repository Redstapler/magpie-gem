module Magpie
  class PropertyFloorLoadRatio < Magpie::Base
    attr_accessor :single_tenant, :multi_tenant
    ensure_number_precision(:single_tenant, 4)
    ensure_number_precision(:multi_tenant, 4)

    def load_from_model(building)
      self.single_tenant = building.floor_load
      self.multi_tenant = building.partial_floor_load

      self
    end

    def model_attributes_base
      {
        floor_load: @single_tenant,
        partial_floor_load: @multi_tenant
      }
    end
  end
end