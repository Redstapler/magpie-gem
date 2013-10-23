require 'magpie-gem/unit_space_type.rb'

module Magpie
  class UnitSpaceTypes < Magpie::Base
    has_one :office, :class => Magpie::UnitSpaceType, :context => 'unit'
    has_one :retail, :class => Magpie::UnitSpaceType, :context => 'unit'
    has_one :industrial, :class => Magpie::UnitSpaceType, :context => 'unit'
    attr_accessor :office, :retail, :industrial

    def use_types
      unless @use_types
        @use_types = @space.use_types.collect(&:name)
        @use_types = ["Office"] if use_types.length == 0
      end
      @use_types
    end

    def load_from_model(space)
      @space = space
      office_rsf = space.office_rsf || 0
      other_rsf = space.available_rsf - office_rsf

      if use_types.length > 0 && use_types[0] == "Industrial"
        @industrial = Magpie::UnitSpaceType.new.load_from_model(space)
        @industrial.available = other_rsf
        @industrial.rate = Magpie::Rate.new(space.warehouse_rate, space.min_asking_rate, space.max_asking_rate)

        if office_rsf > 0
          @office = Magpie::UnitSpaceType.new.load_from_model(space)
          @office.available = space.office_rsf
          @office.rate = Magpie::Rate.new(space.office_rate, space.min_asking_rate, space.max_asking_rate)
        end
      elsif use_types.length > 0 && use_types[0] == "Retail"
        @retail = Magpie::UnitSpaceType.new.load_from_model(space)
        @retail.available = other_rsf
        @retail.rate = Magpie::Rate.new(nil, space.min_asking_rate, space.max_asking_rate)

        if office_rsf > 0
          @office = Magpie::UnitSpaceType.new.load_from_model(space)
          @office.available = space.office_rsf
          @office.rate = Magpie::Rate.new(space.office_rate, space.min_asking_rate, space.max_asking_rate)
        end
      else
        # only office
        @office = Magpie::UnitSpaceType.new.load_from_model(space)
        @office.available = space.available_rsf
        @office.rate = Magpie::Rate.new(nil, space.min_asking_rate, space.max_asking_rate)
      end

      self
    end

    def model_attributes_base
      {
        office_rsf: @office.try(:available),
        office_rate: @office.try(:rate).try(:value),
        warehouse_rate: @industrial.try(:rate).try(:value)
      }
    end

    def as_json(options={})
      {
        office: @office,
        retail: @retail,
        industrial: @industrial
      }
    end
  end
end