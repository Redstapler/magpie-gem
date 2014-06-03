module Magpie
  class UnitLease < Magpie::Base
    attr_accessor :leased_on, :lease_expires_on, :listed_on, :sublease, :coworking, :type, :operating_expenses, :tax, :water_sewege, :electrical, :rate
    has_one :rate, :class => Magpie::Rate, :context => 'unit'

    def initialize
      self.rate = Magpie::Rate.new(nil, nil, nil)
    end

    def load_from_model(space)
      self.leased_on = space.leased_on
      self.lease_expires_on = space.master_lease_expiration
      self.listed_on = space.listed_on
      self.sublease = space.sublease
      self.coworking = space.coworking
      self.type = space.lease_type
      self.operating_expenses = space.operating_expenses

      whatsIncluded = {}
      whatsIncluded['Gross']          = {tax: true, water_sewege: true, electrical: true}
      whatsIncluded['Modified Gross'] = {tax: true, water_sewege: true, electrical: false}
      whatsIncluded['Net']            = {tax: true, water_sewege: true, electrical: false}
      whatsIncluded['Double Net']     = {tax: true, water_sewege: false, electrical: false}
      whatsIncluded['Triple Net']     = {tax: false, water_sewege: false, electrical: false}
      whatsIncluded['Full Service']   = {tax: true, water_sewege: true, electrical: true}

      w = whatsIncluded[@type]
      if w != nil
        w.each {|k,v|
          self.send("#{k}=", v ? 'included' : 'not included')
        }
      end

      if space.min_asking_rate && space.max_asking_rate && space.min_asking_rate != space.max_asking_rate
        self.rate.min_rate = space.min_asking_rate
        self.rate.max_rate = space.max_asking_rate
      else 
        self.rate.rate = space.min_asking_rate || space.office_rate || space.warehouse_rate
      end

      self
    end

    def from_json(json, context=nil)
      super
      self.rate = Magpie::Rate.new.from_json(JSON.parse(json)["rate"].to_json)
      self
    end

    def model_attributes_base
      if @rate.present? && @rate.is_a?(Numeric)
        self.rate = Magpie::Rate.new(@rate, nil, nil)
      end

      {
        leased_on: @leased_on,
        master_lease_expiration: @lease_expires_on,
        listed_on: @listed_on,
        sublease: @sublease,
        coworking: @coworking,
        lease_type: @type,
        operating_expenses: @operating_expenses,
        min_asking_rate: @rate.try(:min_rate) || @rate.try(:value),
        max_asking_rate: @rate.try(:max_rate)
      }
    end
  end
end