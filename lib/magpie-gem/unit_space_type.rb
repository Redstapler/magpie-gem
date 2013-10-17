module Magpie
  class UnitSpaceType < Magpie::Base
    attr_accessor :available, :rate

    def load_from_model(space)
      self
    end

    def model_attributes_base
      {
      }
    end

    def set_attributes(data, context = nil)
      super(data, context)

      if (data['rate'].present?)
        if (data['rate'].is_a? Hash)
          @rate = Magpie::Rate.new(nil, data['rate']['min'], data['rate']['max'])
        else
          @rate = Magpie::Rate.new(data['rate'], nil, nil)
        end
      end
    end

    def total
      @available
    end
  end
end