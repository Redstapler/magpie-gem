module Magpie
  module UseType
    extend ActiveSupport::Concern
    module ClassMethods
      def inherited(klass)
        super
        children << klass
      end

      def children
        @children ||= []
      end

      def use_type(*use_type)
        use_type_qualifiers.concat use_type
      end

      def use_type_qualifiers
        @use_type_qualifiers ||= []
      end

      def use_type?(type)
        use_type_qualifiers.detect{ |qualifier| qualifier === type }
      end

      def build(type, rank = nil)
        (children + [self]).detect{ |klass| klass.use_type?(type) }.new(type, rank)
      end
    end
  end
end