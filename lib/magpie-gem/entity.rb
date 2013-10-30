# Magpie class that corresponds with a real database backed model
module Magpie
  class Entity < Magpie::Base
    attr_accessor :model, :feed_provider, :id, :changes, :action
    validates_presence_of :feed_provider, :id

    def load_from_model(m)
      self.model = m
      self.feed_provider = m.feed_provider
      self.id = m.feed_id.to_s
      self.changes = {}

      self
    end

    def model_attributes_base
      {
        feed_id: @id.to_s,
        feed_provider: @feed_provider,
      }
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

    def lookup_model
      self.class::MODEL_CLASS.where('feed_provider = ?', @feed_provider).where('feed_id = ?', @id.to_s).first
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

    def add_media(attribs)
      self.media << Magpie::Media.new.set_attributes(attribs)
    end
  end
end