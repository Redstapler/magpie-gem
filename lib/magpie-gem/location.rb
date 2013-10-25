module Magpie
  class Location < Magpie::Base
    has_one :postal_address, :class => Magpie::PostalAddress
    attr_accessor :postal_address, :latitude, :longitude, :county
    validates_presence_of :postal_address

    def load_from_model(model)
      self.postal_address = Magpie::PostalAddress.new.load_from_model(model)
      self.latitude = model.location.try(:latitude)
      self.longitude = model.location.try(:longitude)
      self.county = model.county

      self
    end

    def model_attributes_base
      attribs = {
        county: @county
      }

      if @longitude.present? && @latitude.present?
        attribs[:location] = "POINT(#{@longitude} #{@latitude})"
      end

      attribs
    end
  end
end