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
      obj = json.include?('{') ? JSON.parse(json) : json.to_f
      if obj.is_a? Hash
        obj = HashWithIndifferentAccess.new obj
        self.max_rate = (obj[:max].present? && obj[:max].to_f) || nil
        self.min_rate = (obj[:min].present? && obj[:min].to_f) || self.max_rate
      else
        self.rate = obj.to_f
      end
      self.rate ||= self.min_rate unless self.max_rate.present? && self.min_rate != self.max_rate
      self.min_rate ||= self.rate

      self
    end

    def as_json(options = nil)
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