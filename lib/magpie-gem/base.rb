require File.expand_path(File.dirname(__FILE__) + '../../extensions/enumerable.rb')
require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
require_relative 'concerns/serialization'
require_relative 'concerns/validations'
module Magpie
  class Base
    include Validations
    include Serialization
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    cattr_accessor :relationship_classes

    @@relationship_classes = HashWithIndifferentAccess.new


    def self.attr_accessor(*vars)
      add_attributes(vars)
      super
    end

    def self.add_attributes(*vars)
      attributes.concat( vars.flatten )
    end

    def self.attributes
      @attributes ||= []
    end

    def self.attribute?(attrib)
      attributes.include?(attrib.to_sym)
    end

    def initialize(attributes={})
      attributes.try(:each) do |name, value|
        set_attribute(name, value) if self.class.attribute?(name)
      end
    end

    def persisted?
      false
    end

    def self.raise_unless_attribute(attrib)
      raise NameError, "Undefined attribute :#{ attrib } for #{ self.name }" unless attribute?(attrib)
    end

    def self.inspect
      "#<#{ self.to_s} #{ self.attributes.collect{ |e| ":#{ e }" }.join(', ') }>"
    end

    def self.ensure_number_precision(attrib, precision)
      setter_with_feature(attrib, __callee__) do |value|
        value.is_a?(Numeric) ? value.round(precision) : value
      end
    end

    def self.setter_with_feature(attrib, feature_name)
      define_method("#{ attrib }_with_#{ feature_name }=") do |value|
        set_attribute("#{ attrib }_without_#{ feature_name }", yield(value))
      end
      alias_method_chain "#{ attrib }=", feature_name
    end

    def self.getter_with_feature(attrib, feature_name)
      define_method("#{ attrib }_with_#{ feature_name }") do |value|
        yield public_send("#{ attrib }_without_#{ feature_name }")
      end
      alias_method_chain "#{ attrib }", feature_name
    end

    def attributes=(data)
      set_attributes(data, nil)
    end

    def set_attribute(attribute_name, value, options = {})
      method = "#{attribute_name}="
      return send(method, value) if respond_to? method

      if options[:strict]
        self.class.raise_unless_attribute(attribute_name)
      else
        instance_variable_set("@#{ attribute_name }", value)
      end
    end

    def set_attributes(data, options = {})
      context, options = extract_context(options)

      data.each do |key, value|
        val = extract_magpie_instance(key, value, context)
        set_attribute(key, val, options)
      end
      self
    end

    def extract_context(options)
      if options.is_a? Hash
        [options.delete(:context), options]
      else
        [options, {}]
      end
    end

    def extract_magpie_instance(key, value, context = nil)
      case value
      when Hash
        item_class(context, key).try do |klass|
          klass.new.from_json(value.to_json, context)
        end || value
      when Array
        item_class(context, key).try do |klass|
          value.map { |item| klass.new.from_json(item.to_json, context) }
        end || value
      else
        value
      end
    end

    def item_class(context = nil, key)
      self.class.relationship_classes["#{context}#{key}"] || self.class.relationship_classes[key]
    end

    def self.has_many(attribute_name, options={})
      self.relationship_classes["#{options[:context]}#{attribute_name}"] = options[:class] || attribute_name.to_s.singularize.classify.constantize
    end

    def self.has_one(attribute_name, options={})
      self.relationship_classes["#{options[:context]}#{attribute_name}"] = options[:class] || attribute_name.to_s.classify.constantize
    end

    def attributes
      instance_values
    end

    def model_attributes(level=0)
      # puts "#{'-'*level} Calling model_attributes for #{self.class}"
      model_attrs = model_attributes_base
      attributes.except(*exclude_from_model_attributes).each do |attr, value|

        case value
        when Magpie::Base
          model_attrs.merge! value.model_attributes(level+1)
        when Array
          value.each do |item|
            model_attrs.merge! item.model_attributes(level+1) if item.is_a? Magpie::Base
          end
        when Hash
          value.each do |k, v|
            model_attrs.merge! v.model_attributes(level+1) if v.is_a? Magpie::Base
          end
        end

      end
      sanitize_model_attributes(model_attrs).reject{|k,v| null?(v) }
    end

    def null?(v)
      v.nil? || v=="null" || v=="nil" || v=="N/A" || v.to_s.downcase=="nan" || v == "POINT( )"
    end

    def model_attributes_base
      {}
    end

    def exclude_from_model_attributes
      []
    end

    def sanitize_model_attributes(attrs)
      attrs
    end


    def self.each_entity_class
      [Magpie::Company, Magpie::Person, Magpie::Property, Magpie::Unit].each {|entity_class|
        entity_name = entity_class.name.demodulize.underscore
        entity_name_plural = entity_name.pluralize

        yield entity_class, entity_name, entity_name_plural
      }
    end

  end
end