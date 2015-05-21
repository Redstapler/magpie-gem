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
      @attributes ||= []
      @attributes.concat( vars )
      super
    end

    def self.attributes
      @attributes
    end

    def initialize(attributes={})
      attributes && attributes.each do |name, value|
        send("#{name}=", value) if respond_to? name.to_sym 
      end
    end

    def persisted?
      false
    end

    def self.inspect
      "#<#{ self.to_s} #{ self.attributes.collect{ |e| ":#{ e }" }.join(', ') }>"
    end

    def self.ensure_number_precision(attrib, precision)
      define_method("#{attrib}=") do |value|
        if value.try(:is_a?, Numeric)
          self.instance_variable_set("@#{attrib}", value.round(precision))
        else
          self.instance_variable_set("@#{attrib}", value)
        end
      end
    end

    def attributes=(data)
      set_attributes(data, nil)
    end

    def set_attributes(data, context = nil)
      # puts "#{self.class.name} set_attributes with context #{context}"
      data.each do |key, value|
        case value
        when Hash
          item_class = @@relationship_classes["#{context}#{key}"] || @@relationship_classes[key]
          # puts "key = #{key}, item_class = #{item_class}"
          if item_class
            # puts "  creating #{item_class.name} with context #{context}"
            value = item_class.new.from_json(value.to_json, context)
          end

          instance_variable_set("@#{key}", value)
        when Array
          item_class = @@relationship_classes["#{context}#{key}"] || @@relationship_classes[key]

          arr = value
          if item_class
            arr = arr.collect{|item|
              # puts "  creating #{item_class.name} with context #{context}"
              item_class.new.from_json(item.to_json, context)
            }
          end

          instance_variable_set("@#{key}", arr)
        else
          instance_variable_set("@#{key}", value)
        end
      end
      self
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
      sanitize_model_attributes(model_attrs).reject{|k,v| v.nil? || v=="null" || v=="nil" || v=="N/A" || v.to_s.downcase=="nan" || v == "POINT( )"}
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