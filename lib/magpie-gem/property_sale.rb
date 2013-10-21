module Magpie
  class PropertySale < Magpie::Base
    attr_accessor :for_sale, :sale_price, :cap_rate, :sale_status

    ensure_number_precision(:sale_price, 2)
    ensure_number_precision(:cap_rate, 2)
    
    def load_from_model(model)
      self.for_sale = model.for_sale
      self.sale_price = model.sale_price
      self.cap_rate = model.cap_rate
      self.sale_status = model.sale_status

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
end