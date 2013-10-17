module Magpie
  class PropertyBuilt < Magpie::Base
    attr_accessor :year_built, :year_renovated, :number_buildings, :number_floors, :leed_certification, :construction_status, :class_rating

    def load_from_model(model)
      @year_built = model.year_built
      @year_renovated = model.year_renovated
      @number_buildings = model.number_buildings
      @number_floors = model.number_floors
      @leed_certification = model.leed_certification
      @construction_status = model.construction_status
      @class_rating = model.class_rating

      self
    end

    def model_attributes_base
      {
        year_built: @year_built,
        year_renovated: @year_renovated,
        number_buildings: @number_buildings,
        number_floors: @number_floors,
        leed_certification: @leed_certification,
        construction_status: @construction_status,
        class_rating: @class_rating
      }
    end

  end
end