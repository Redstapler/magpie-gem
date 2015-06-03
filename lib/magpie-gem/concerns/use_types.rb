module Magpie
  module UseTypes
    extend ActiveSupport::Concern

    module ClassMethods
      def use_types
        @types ||= Set.new
      end

      def register_use_types(*types)
        use_types.merge(types.flatten)
      end

      def attributes
        (use_types + super).to_a
      end

      def expose_use_types(*types)
        options = types.extract_options!
        types.each do |type|
          validate_use_type(type)
          has_one type, options.slice(:class, :context)
          define_use_type_reader(type, options)
          define_use_type_writer(type, options)
        end

        register_use_types(types)
      end

      def validate_use_type(type)
        raise TypeError, "Unhandled type declaration #{ type }" unless type.is_a? Symbol
        raise NameError, "#{ self.name }##{ type } already defined" if method_defined? type
      end

      def define_use_type_reader(type, options = {})
        klass = options.fetch(:class)
        define_method(type) do
          types_hash[type] ||= klass.new
        end
      end

      def define_use_type_writer(type, options = {})
        klass = options.fetch(:class)
        enfoce_type = options[:enfoce_type]

        define_method("#{type}=") do |val|
          if enfoce_type && !val.is_a?(klass)
            raise TypeError, "#{ type } must be type #{ klass }, received type #{ val.class }"
          end
          types_hash[type] = val
        end
      end
    end


    def types_hash
      @types_hash ||= {}
    end

    def as_json(options = {})
      types_hash.each_with_object({}){ |(key, value), hash| hash[key] = value.as_json }
    end
  end
end