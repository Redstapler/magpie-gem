module Magpie
  class Rate < Magpie::Base
    attr_accessor :rate, :min_rate, :max_rate
    ensure_number_precision(:rate, 4)
    ensure_number_precision(:min_rate, 4)
    ensure_number_precision(:max_rate, 4)

    def initialize(rate, min_rate, max_rate)
      self.rate = rate || min_rate
      self.min_rate = min_rate || rate
      self.max_rate = max_rate
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