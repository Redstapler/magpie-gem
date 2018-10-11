require 'magpie-gem/property_space_type_lease.rb'
require 'magpie-gem/rate.rb'
require_relative 'concerns/use_type'

module Magpie
  class PropertySpaceType < Magpie::Base
    include UseType

    attr_accessor :total, :lease, :rate, :specific_rate, :sub_type, :type, :rank
    has_one :lease, :class => Magpie::PropertySpaceTypeLease, :context => 'property'

    ensure_number_precision(:specific_rate, 4)
    ensure_number_precision(:total, 4)
    use_type ->(type){ true } #all use types

    def initialize(type = nil, rank = nil)
      self.rate = Magpie::Rate.new(nil, nil, nil)
      self.lease = Magpie::PropertySpaceTypeLease.new
      self.type = type
      self.rank = rank
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