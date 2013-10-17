class Magpie::PropertyLand < Magpie::Base
  attr_accessor :acres, :corner_lot, :will_build_to_suit

  def load_from_model(model)
    @acres = model.acres
    @corner_lot = model.corner_lot
    @will_build_to_suit = model.will_build_to_suit

    self
  end

  def model_attributes_base
    {
      acres: @acres,
      corner_lot: @corner_lot,
      will_build_to_suit: @will_build_to_suit
    }
  end
end