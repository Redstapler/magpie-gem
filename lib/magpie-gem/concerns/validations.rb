module Magpie
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      cattr_accessor :validate_json

      validate do
        attributes.except(*exclude_from_model_attributes).each do |attr, value|
          if value.is_a? Magpie::Base
            unless value.valid?
              prefix = self.class.name.demodulize.underscore
              if self.is_a? Magpie::Entity
                prefix = "#{prefix}_#{@id}"
              end
              value.errors.messages.each{|k,v|
                self.errors.messages[(prefix + ' / ' + k.to_s).to_sym] = v
              }
            end
          end
        end
      end

    end

    class Error < StandardError
      def initialize(model)
        @model = model
        super(extract_message(model))
      end
      attr_reader :model

      private
      def extract_message(model)
        "Validation errors: #{model.errors.messages}"
      end
    end

    def validate_model_attributes
    end

    def validate_model_attributes_presence attribs_to_validate, attribs
      prefix = self.class.name.demodulize.underscore
      if self.is_a? Magpie::Entity
        prefix = "#{prefix}_#{@id}"
      end

      attribs_to_validate.each do |attrib|
        # puts "Validating #{attrib} for #{prefix} - has value '#{attribs[attrib]}' #{attribs[attrib].blank?}"
        self.errors.messages["#{prefix} / model / #{attrib}".to_sym] = ["can't be blank"] if attribs[attrib].blank?
      end
    end

    def valid?
      super
      validate_model_attributes
      self.errors.messages.count == 0
    end

    def validate
      valid?
      # throw "Validation errors: #{self.errors.full_messages}\nmodel = #{self.inspect}" unless self.errors.messages.count == 0
    end

    def error_instance
      Error.new(self)
    end
  end
end
