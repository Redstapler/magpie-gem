require 'magpie-gem/unit_space_type.rb'

module Magpie
  class UnitSpaceTypes < Magpie::Base

    class << self
      def expose_types(*types)
        raise "Types must be Symbols" unless types.all?{ |type| type.is_a? Symbol }
        types.each do |type|
          has_one type, class: Magpie::UnitSpaceType, context: 'unit'
          attr_writer(type)
          define_method(type) do
            variable_name = "@#{ type }"
            value = instance_variable_get(variable_name)
            return value if value
            instance_variable_set(variable_name, Magpie::UnitSpaceType.new)
          end
        end

        use_types.merge types
      end

      def use_types
        @types ||= Set.new
      end
    end

    expose_types :office, :industrial, :retail

    def use_types
      unless @use_types
        @use_types = @space.use_types.collect(&:name)
        @use_types = ["Office"] if use_types.length == 0
      end
      @use_types
    end

    def load_from_model(space)
      @space = space
      office_rsf = space.office_rsf || 0
      other_rsf = space.available_rsf - office_rsf

      if use_types.length > 0 && use_types[0] == "Industrial"
        industrial.load_from_model(space)
        industrial.available = other_rsf
        industrial.rate = Magpie::Rate.new(space.warehouse_rate, space.min_asking_rate, space.max_asking_rate)

        if office_rsf > 0
          office.load_from_model(space)
          office.available = space.office_rsf
          office.rate = Magpie::Rate.new(space.office_rate, space.min_asking_rate, space.max_asking_rate)
        end
      elsif use_types.length > 0 && use_types[0] == "Retail"
        retail.load_from_model(space)
        retail.available = other_rsf
        retail.rate = Magpie::Rate.new(nil, space.min_asking_rate, space.max_asking_rate)

        if office_rsf > 0
          office.load_from_model(space)
          office.available = space.office_rsf
          office.rate = Magpie::Rate.new(space.office_rate, space.min_asking_rate, space.max_asking_rate)
        end
      else
        # only office
        office.load_from_model(space)
        office.available = space.available_rsf
        office.rate = Magpie::Rate.new(nil, space.min_asking_rate, space.max_asking_rate)
      end

      self
    end

    def model_attributes_base
      {
        office_rsf: office.try(:available),
        office_rate: office.try(:rate).try(:value),
        warehouse_rate: industrial.try(:rate).try(:value)
      }
    end

    def as_json(options={})
      Hash[
        self.class.use_types.map do |type|
          [type, public_send(type).as_json]
        end
      ].reject{|k,v| v.nil? || v.empty?}
    end
  end
end