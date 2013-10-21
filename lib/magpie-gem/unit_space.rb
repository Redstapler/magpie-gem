require 'magpie-gem/unit_space_types.rb'

module Magpie
  class UnitSpace < Magpie::Base
    has_one :types, :class => Magpie::UnitSpaceTypes, :context => 'unit'

    attr_accessor :available, :divisible_by, :largest_contiguous_space, :types
    ensure_number_precision(:available, 0)
    ensure_number_precision(:divisible_by, 0)
    ensure_number_precision(:largest_contiguous_space, 0)

    def load_from_model(space)
      self.available = space.available_rsf
      self.divisible_by = space.divisible_rsf
      self.largest_contiguous_space = space.contiguous_rsf

      self.types = Magpie::UnitSpaceTypes.new.load_from_model(space)

      self
    end

    def model_attributes_base
      {
        available_rsf: @available,
        divisible_rsf: @divisible_by,
        contiguous_rsf: @largest_contiguous_space
      }
    end
  end
end