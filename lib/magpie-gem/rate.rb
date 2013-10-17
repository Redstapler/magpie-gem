module Magpie
  class Rate < Magpie::Base
    attr_accessor :rate, :min_rate, :max_rate

    validates_presence_of :rate, :min_rate

    def initialize(rate, min_rate, max_rate)
      @rate = rate || min_rate
      @min_rate = min_rate || rate
      @max_rate = max_rate
    end

    def as_json(options)
      if @rate.present?
        @rate
      else
        { min: @min_rate, max: @max_rate }
      end
    end

    def value
      @rate || @min_rate || @max_rate
    end
  end
end