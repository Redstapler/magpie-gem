module Magpie
  class Location < Magpie::Base
    has_one :postal_address, :class => Magpie::PostalAddress
    attr_accessor :postal_address, :latitude, :longitude, :county, :formatted_long_address
    validates_presence_of :postal_address

    def initialize
      self.postal_address = Magpie::PostalAddress.new
    end

    def load_from_model(model)
      self.postal_address.load_from_model(model)
      self.latitude = model.location.try(:latitude)
      self.longitude = model.location.try(:longitude)
      self.county = model.county
      self.formatted_long_address = model.location.try(:formatted_long_address)

      self
    end

    def model_attributes_base
      attribs = {
        county: @county
      }

      if @longitude.present? && @latitude.present?
        attribs[:location] = "POINT(#{@longitude} #{@latitude})"
      end
      if @formatted_long_address.present?
        attribs[:formatted_long_address] = @formatted_long_address
      end
      attribs
    end
  end
end