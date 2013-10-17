class Magpie::PostalAddress < Magpie::Base
  attr_accessor :street1, :street2, :city, :state, :country, :postal_code

  def load_from_model(model)
    @street1 = model.try(:address1) rescue model.try(:address)
    @street2 = model.try(:address2) rescue nil
    @city = model.city
    @state = model.state
    @country = model.country
    @postal_code = model.postal_code

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