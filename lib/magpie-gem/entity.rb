# Magpie class that corresponds with a real database backed model
module Magpie
  class Entity < Magpie::Base
    class << self
      alias_method :config, :tap
    end

    validates_presence_of :feed_provider, :id

    attr_accessor :feed_provider, :id, :model, :changes, :action

    def load_from_model(m)
      self.model = m
      self.feed_provider = m.feed_provider
      self.id = m.feed_id.to_s
      self.changes = {}

      self
    end

    def model_attributes_base
      {
        feed_id: id.to_s,
        feed_provider: feed_provider,
      }
    end

    def lookup_model
      model_class.where('feed_provider = ?', feed_provider).where('feed_id = ?', id.to_s).first
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

    def do_save(options = {})
    end

    def build_attrs(options = {})
      only   = options[:only]
      except = options[:except]
      raise "Can't use :only and :except. Choose one or the other." if only && except
      attrs = if only
                model_attributes.slice(*only)
              elsif except
                model_attributes.except(*except)
              else
                model_attributes
              end

      attrs.each{ |k,v| attrs[k] = v.to_s if v.try(:is_a?, Numeric) }
    end

    def save_model(options = {})
      assign_attributes_to_model(build_attrs(options))
      return false unless self.model.changed?
      self.changes = self.model.changes
      self.model.save!
      self.model.reload
      true
    end

    def assign_attributes_to_model(attrs)
      self.model.assign_attributes(attrs, without_protection: true)
    end

    def model_class
      self.class::MODEL_CLASS
    end

    def dedup_attributes
      self.class::DEDUP_ATTRIBUTES
    end

    def lookup_attributes
      @lookup_attributes ||= model_attributes.slice(*dedup_attributes)
    end

    def lookup_attrs_scope
      @lookup_attrs_scope ||= model_class.where(lookup_attributes)
    end

    def prepare_model_for_save
      self.model ||= lookup_model

      if self.model
        return :skip_override if self.model.feed_override # We own it now, so don't let feed update it
        self.model.reload
      elsif dedup_attributes && lookup_attributes.values.any?
        # Skip if the building is found in the database independent of the feed provider (manually added, etc.)

        # Looks up if the dedup attributes match along with the same feed provider
        lookup_attrs_scope.where("feed_id is null").where(feed_provider: feed_provider).first.try do |m|
          self.model = m
          return check_for_feed_override(m, :ready)
        end

        # Check to see if it is a duplicate but not from any feed
        lookup_attrs_scope.where("feed_provider is null").first.try do |m|
          self.model = m
          return check_for_feed_override(m, :skip_manual_input)
        end

        lookup_attrs_scope.first.try do |b|
          self.model = b
          return :skip_independent
        end
      end

      return :ready
    end

    def check_for_feed_override(model_instance, return_symbol)
      return :skip_override if model_instance.feed_override
      return return_symbol
    end

    def add_media(attribs)
      self.media << Magpie::Media.new.set_attributes(attribs)
    end
  end


end
