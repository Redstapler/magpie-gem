module Magpie
  class Location < Magpie::Base
    has_one :postal_address, :class => Magpie::PostalAddress
    attr_accessor :postal_address, :latitude, :longitude, :county
    validates_presence_of :postal_address

    def load_from_model(model)
      @postal_address = Magpie::PostalAddress.new.load_from_model(model)
      @latitude = model.location.try(:latitude)
      @longitude = model.location.try(:longitude)
      @county = model.county

      self
    end

    def model_attributes_base
      {
        county: @county,
        location: "POINT(#{@longitude} #{@latitude})"
      }
    end

  end
end