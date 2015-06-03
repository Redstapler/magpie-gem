module Magpie
  def self.snakecase_use_type(use_type)
    use_type.to_s.gsub(/\W/, '').underscore
  end

  module UseTypes
    extend ActiveSupport::Concern

    module ClassMethods
      def use_types
        @use_types ||= Set.new
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
          set_type(type){ klass.build(type) }
        end
      end

      def define_use_type_writer(type, options = {})
        klass = options.fetch(:class)
        enforce_type = options[:enforce_type]

        define_method("#{type}=") do |val|
          if enforce_type && !val.is_a?(klass)
            raise TypeError, "#{ type } must be type #{ klass }, received type #{ val.class }"
          end
          types_hash[type] = val
        end
      end
    end

    def set_type(type)
      types_hash[type] ||= yield
    end

    def types_hash
      @types_hash ||= {}
    end

    def attribute_keys
      super - uninitialized_use_types.to_a
    end

    def attributes
      super
    end

    def uninitialized_use_types
      self.class.use_types - types_hash.keys
    end

    def exclude_from_model_attributes
      uninitialized_use_types.map(&:to_s)
    end
  end
end