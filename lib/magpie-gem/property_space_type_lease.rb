module Magpie
  class PropertySpaceTypeLease < Magpie::Base
    attr_accessor :type, :tax, :water_sewege, :electrical, :operating_expenses
    ensure_number_precision(:operating_expenses, 4)
    
    def load_from_model(building)
      self.type = building.lease_type
      self.operating_expenses = building.operating_expenses

      whatsIncluded = {}
      whatsIncluded['Gross']          = {tax: true, water_sewege: true, electrical: true}
      whatsIncluded['Modified Gross'] = {tax: true, water_sewege: true, electrical: false}
      whatsIncluded['Net']            = {tax: true, water_sewege: true, electrical: false}
      whatsIncluded['Double Net']     = {tax: true, water_sewege: false, electrical: false}
      whatsIncluded['Triple Net']     = {tax: false, water_sewege: false, electrical: false}
      whatsIncluded['Full Service']   = {tax: true, water_sewege: true, electrical: true}

      w = whatsIncluded[@type]
      self.tax = included_message w[:tax]
      self.water_sewege = included_message w[:water_sewege]
      self.electrical = included_message w[:electrical]

      self
    end

    def included_message(included)
      included ? 'included' : 'not included'
    end

    def model_attributes_base
      {
        lease_type: @type,
        operating_expenses: @operating_expenses
      }
    end
  end
end