class Magpie::UnitSpace < Magpie::Base
  has_one :types, :class => Magpie::UnitSpaceTypes, :context => 'unit'

  attr_accessor :available, :divisible_by, :largest_contiguous_space, :types

  def load_from_model(space)
    @available = space.available_rsf
    @divisible_by = space.divisible_rsf
    @largest_contiguous_space = space.contiguous_rsf

    @types = Magpie::UnitSpaceTypes.new.load_from_model(space)

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