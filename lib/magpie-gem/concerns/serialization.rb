module Magpie
  module Serialization
    extend ActiveSupport::Concern
    include ActiveModel::Serializers::JSON

    def as_json(options={})
      options ||= {}
      options[:except] = ((options[:except] || []) << [:errors, :validation_context, :model_class, :precisions]).flatten
      super.as_json(options).clean!
    end

    # To json with validations
    def to_json(options = {})
      raise Validations::Error.new(self) unless valid?
      super
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json)
      self.set_attributes(obj, context)
      self
    end

  end
end