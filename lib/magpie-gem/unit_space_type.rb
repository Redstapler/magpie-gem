require 'magpie-gem/rate.rb'

module Magpie
  class UnitSpaceType < Magpie::Base
    attr_accessor :available, :rate, :sub_type, :type, :rank
    ensure_number_precision(:available, 0)

    def self.build(type, rank = nil)
      new(type, rank)
    end

    def initialize(type = nil, rank = nil)
      self.rate = Magpie::Rate.new(nil, nil, nil)
      self.type = type
      self.rank = rank
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