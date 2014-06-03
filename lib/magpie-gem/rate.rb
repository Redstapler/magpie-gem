module Magpie
  class Rate < Magpie::Base
    attr_accessor :rate, :min_rate, :max_rate
    ensure_number_precision(:rate, 4)
    ensure_number_precision(:min_rate, 4)
    ensure_number_precision(:max_rate, 4)

    def initialize(rate = nil, min_rate = nil, max_rate = nil)
      self.rate = rate || min_rate
      self.min_rate = min_rate || rate
      self.max_rate = max_rate
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json)
      if obj.is_a? Hash
        obj = HashWithIndifferentAccess.new obj
        self.min_rate = obj[:min].to_f
        self.max_rate = obj[:max].to_f
      else
        self.rate = obj.to_f
      end
      self.rate ||= self.min_rate
      self.min_rate ||= self.rate

      self
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