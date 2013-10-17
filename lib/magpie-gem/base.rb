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
      (options[:except] ||= []) << [:errors, :validation_context, :model_class]
      if options[:include_root].present? && options[:include_root]
        json = super.as_json(options)
      else
        json = super.as_json(options)[self.class.name.demodulize.underscore]
      end

      json.clean!
    end

    def from_json(json, context=nil)
      # puts "Creating #{self.class.name} with #{json}"

      obj = JSON.parse(json)
      self.set_attributes(obj, context)
      self
    end

    def prepare_model_for_save
      if @model ||= lookup_model
        return false if @model.feed_override # We own it now, so don't let feed update it
        @model.reload
      elsif @dedup_attributes
        # Skip if the building is found in the database independent of the feed provider (manually added, etc.)
        lookup_attributes = model_attributes.slice(*@dedup_attributes)
        if lookup_attributes.values.compact.length > 0
          b = @model_class.where("feed_provider is null or feed_provider != '#{@feed_provider}'").where(lookup_attributes).first
          if b
            @model = b
            return false
          end
        end
      end

      return true
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
      sanitize_model_attributes model_attrs
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
      return nil unless prepare_model_for_save

      ActiveRecord::Base.transaction do
        do_save(options)
      end
    end

  protected
    def use_types
      ut = [:office, :retail, :industrial].collect{|k| UseType.find_by_code k if @space.types.send(k).try(:total)}.compact
      ut = [UseType.find_by_name('Office')] unless ut && ut.length > 0
      ut
    end

    def upload_media_assets(obj, options={})
      unless options[:skip_photos] || @media.nil? || @media.length == 0
        upload_atts = { attached_type: options[:type] || 'Building', attached_id: obj.id }
        delete_list = obj.uploads.collect(&:source_url)
        @media.each do |media|
          upload_atts.merge!({ source_url: media.url, kind: media.kind })
          Upload.create(upload_atts, without_protection: true) unless Upload.where(upload_atts).exists? || DeletedUpload.where(source_url: media.url).exists?
          delete_list.delete media.url
        end

        obj.uploads.where('source_url in (?)', delete_list).map(&:destroy)
      end
    end

    def update_contacts(obj, data)
      current_contacts_by_email = obj.contacts.index_by{|c| c.person.email }
      contacts_to_delete = obj.contacts.collect(&:id)
      data.each {|c|
        if current_contact = current_contacts_by_email[c.email]
          if current_contact.role != c.role
            current_contact.update_attributes!(role: c.role)
          end
          contacts_to_delete.delete current_contact.id
        else
          obj.contacts.create(:person => Person.find_by_email(c.email), :role => c.role, :send_leads => true)
        end
      } unless data.nil?
      Contact.where('id in (?)', contacts_to_delete).map(&:destroy)
    end
  end
end