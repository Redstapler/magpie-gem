class Magpie::PropertySpaceTypes < Magpie::Base
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
    puts "in PropertySpaceTypes::from_json with #{json}"
    obj = JSON.parse(json).slice(:office, :retail, :industrial)
    puts "after slice #{obj.to_json}"
    self.set_attributes(obj, context)
    self
  end

  def model_attributes_base
    {
    }
  end
end