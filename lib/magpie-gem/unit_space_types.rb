require_relative 'concerns/use_types'
require_relative 'unit_space_type'

module Magpie
  class UnitSpaceTypes < Magpie::Base
    include UseTypes
    expose_use_types  :office,
                      :retail,
                      :industrial,
                      :office_retail_mixed,
                      :flex_space,
                      :land,
                      :multi_family,
                      :medical_office,
                      class: UnitSpaceType, context: 'unit', enforce_type: true

    def load_from_model(space)
      default_use_type = "Office".freeze
      use_types        = space.use_types.map(&:name).presence || [default_use_type]
      office_rsf       = space.office_rsf || 0
      other_rsf        = space.available_rsf - office_rsf

      case use_types[0]
      when "Industrial"
        industrial.load_from_model(space)
        industrial.available = other_rsf
        industrial.rate = Magpie::Rate.new(space.warehouse_rate, space.min_asking_rate, space.max_asking_rate)
        load_additional_office(space) if office_rsf > 0
      when "Retail"
        retail.load_from_model(space)
        retail.available = other_rsf
        retail.rate = Magpie::Rate.new(nil, space.min_asking_rate, space.max_asking_rate)
        load_additional_office(space) if office_rsf > 0
      when default_use_type
        office.load_from_model(space)
        office.available = space.available_rsf
        office.rate = Magpie::Rate.new(nil, space.min_asking_rate, space.max_asking_rate)
      end
      self
    end

    def load_additional_office(space)
      office.load_from_model(space)
      office.available = space.office_rsf
      office.rate = Magpie::Rate.new(space.office_rate, space.min_asking_rate, space.max_asking_rate)
    end

    def model_attributes_base
      {
        office_rsf: types_hash[:office].try(:available),
        office_rate: types_hash[:office].try(:rate).try(:value),
        warehouse_rate: types_hash[:industrial].try(:rate).try(:value)
      }
    end

    def as_json(options = {})
      types_hash
      .each_with_object({}){ |(key, value), hash| hash[key] = value.as_json }
      .reject{ |k,v| v.nil? || v.empty? }
    end

  end
end