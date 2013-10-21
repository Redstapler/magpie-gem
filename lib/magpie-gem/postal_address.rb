module Magpie
  class PostalAddress < Magpie::Base
    attr_accessor :street1, :street2, :city, :state, :country, :postal_code

    def load_from_model(model)
      self.street1 = model.try(:address1) rescue model.try(:address)
      self.street2 = model.try(:address2) rescue nil
      self.city = model.city
      self.state = model.state
      self.country = model.country
      self.postal_code = model.postal_code

      self
    end

    def model_attributes_base
      {
        address1: @street1,
        address2: @street2,
        city: @city,
        state: @state,
        country: @country,
        postal_code: @postal_code
      }
    end
  end
end