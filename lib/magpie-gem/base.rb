require File.expand_path(File.dirname(__FILE__) + '../../extensions/enumerable.rb')
require 'active_model'
require 'active_support/core_ext/hash/indifferent_access'
module Magpie
  class Base
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    cattr_accessor :relationship_classes

    @@relationship_classes = HashWithIndifferentAccess.new

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
        if value.present? && value.is_a?(Numeric)
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
        if value.is_a? Hash
          item_class = @@relationship_classes["#{context}#{key}"] || @@relationship_classes[key]
          # puts "key = #{key}, item_class = #{item_class}"
          if item_class
            # puts "  creating #{item_class.name} with context #{context}"
            value = item_class.new.from_json(value.to_json, context)
          end

          instance_variable_set("@#{key}", value)
        elsif value.is_a? Array
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

    def as_json(options={})
      options ||= {}
      options[:except] = ((options[:except] || []) << [:errors, :validation_context, :model_class, :precisions]).flatten
      super.as_json(options).clean!
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json)
      self.set_attributes(obj, context)
      self
    end

    def prepare_model_for_save
      if @model ||= lookup_model
        return :skip_override if @model.feed_override # We own it now, so don't let feed update it
        @model.reload
      elsif self.class::DEDUP_ATTRIBUTES
        # Skip if the building is found in the database independent of the feed provider (manually added, etc.)
        lookup_attributes = model_attributes.slice(*self.class::DEDUP_ATTRIBUTES)
        if lookup_attributes.values.compact.length > 0
          b = self.class::MODEL_CLASS.where("feed_provider is null or feed_provider != '#{@feed_provider}'").where(lookup_attributes).first
          if b
            @model = b
            return :skip_independent
          end
        end
      end

      return :ready
    end
    
    def model_attributes(level=0)
      # puts "#{'-'*level} Calling model_attributes for #{self.class}"
      model_attrs = model_attributes_base
      attributes.except(*exclude_from_model_attributes).each do |attr, value|
        if value.is_a? Magpie::Base
          model_attrs.merge! value.model_attributes(level+1)
        elsif value.is_a? Array
          value.each do |item|
            model_attrs.merge! item.model_attributes(level+1) if item.is_a? Magpie::Base
          end
        elsif value.is_a? Hash
          value.each do |k, v|
            model_attrs.merge! v.model_attributes(level+1) if v.is_a? Magpie::Base
          end
        end
      end
      sanitize_model_attributes(model_attrs).reject{|k,v| v.nil? || v=="null" || v=="nil" || v=="N/A" || v.to_s.downcase=="nan"}
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

    def save(options={})
      action = prepare_model_for_save
      if action == :ready
        ActiveRecord::Base.transaction do
          action = do_save(options)
        end
      end

      action
    end

    def save_model
      # Rails.logger.info("=> @model = #{@model.inspect}")
      # Rails.logger.info("=> attributes = #{model_attributes}")
      attrs = model_attributes
      attrs.each{|k,v|
        if v.present? && v.is_a?(Numeric)
          attrs[k] = v.to_s
        end
      }
        
      @model.assign_attributes(attrs, without_protection: true)
      # Rails.logger.info("<== @model = #{@model.inspect}")
      validate

      if @model.changed?
        @changes = @model.changes
        # Rails.logger.info("!!!! #{@model.class.name} #{@model.feed_id} changed: #{@model.changes} model attributes: #{attrs}")
        @model.save!
        @model.reload
        true
      else
        false
      end
    end
  end
end