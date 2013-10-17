class Magpie::PropertySale < Magpie::Base
  attr_accessor :for_sale, :sale_price, :cap_rate, :sale_status

  def load_from_model(model)
    @for_sale = model.for_sale
    @sale_price = model.sale_price
    @cap_rate = model.cap_rate
    @sale_status = model.sale_status

    self
  end

  def model_attributes_base
    {
      for_sale: @for_sale,
      sale_price: @sale_price,
      cap_rate: @cap_rate,
      sale_status: @sale_status
    }
  end
end