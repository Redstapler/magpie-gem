require 'magpie-gem/rate.rb'

module Magpie
  class UnitSpaceType < Magpie::Base
    attr_accessor :available, :rate
    ensure_number_precision(:available, 0)

    def initialize
      self.rate = Magpie::Rate.new(nil, nil, nil)
    end

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
          self.rate = Magpie::Rate.new(nil, data['rate']['min'], data['rate']['max'])
        else
          self.rate = Magpie::Rate.new(data['rate'], nil, nil)
        end
      end
    end

    def total
      @available
    end
  end
end