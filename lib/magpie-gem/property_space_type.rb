require 'magpie-gem/property_space_type_lease.rb'
require 'magpie-gem/rate.rb'

module Magpie
  class PropertySpaceType < Magpie::Base
    attr_accessor :total, :lease, :rate, :specific_rate
    has_one :lease, :class => Magpie::PropertySpaceTypeLease, :context => 'property'

    ensure_number_precision(:specific_rate, 4)
    ensure_number_precision(:total, 4)

    def initialize
      self.rate = Magpie::Rate.new(nil, nil, nil)
      self.lease = Magpie::PropertySpaceTypeLease.new
    end

    def load_from_model(building)
      # fill in only if total is present for this type of space
      return if @total.nil? || @total <= 0

      self.lease.load_from_model(building)
      if @specific_rate.present?
        self.rate.rate = @specific_rate
      else
        self.rate.min_rate = building.min_asking_rate
        self.rate.max_rate = building.max_asking_rate
      end

      self
    end

    def model_attributes_base
      {
        min_asking_rate: @rate.try(:min_rate),
        max_asking_rate: @rate.try(:max_rate)
      }
    end
  end
end