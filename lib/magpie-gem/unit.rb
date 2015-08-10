require 'magpie-gem/unit_space.rb'
require 'magpie-gem/unit_lease.rb'
require 'magpie-gem/contact.rb'
require 'magpie-gem/media.rb'
require 'magpie-gem/unit_amenities.rb'

module Magpie
  class Unit < Magpie::Entity
    DEDUP_ATTRIBUTES = nil

    validates_presence_of :feed_sources

    attr_accessor :property
    attr_accessor :property_id, :name, :floor, :suite, :status, :available_on, :contacts, :space, :lease, :media, :amenities
    has_many :contacts, :class => Magpie::Contact
    has_one :space, :class => Magpie::UnitSpace, :context => 'unit'
    has_one :lease, :class => Magpie::UnitLease
    has_many :media, :class => Magpie::Media
    has_one :amenities, :class => Magpie::UnitAmenities, :context => 'unit'

    class << self
      def import_status_values
        @import_status_values ||= ["Off Market", "Available", "Lease Pending", "Leased", "Vacant"].freeze
      end

      def osnext_status_values
        @osnext_status_values ||= []
      end

      def osnext_status_values=(value)
        @osnext_status_values = value
      end

      def status_values
        import_status_values + osnext_status_values
      end
    end

    validates :status, inclusion: {
      in: proc { status_values },
      message: proc { "'%{value}' is not a valid status: #{ status_values.inspect }" }
    }

    def initialize
      self.contacts = []
      self.space = Magpie::UnitSpace.new
      self.lease = Magpie::UnitLease.new
      self.media = []
      self.amenities = Magpie::UnitAmenities.new
    end

    def load_from_model(space)
      super(space)

      self.name = space.name
      self.floor = space.floor
      self.suite = space.suite
      self.status = space.status
      self.available_on = space.available_on
      self.contacts = Magpie::Contact.load_contacts_from_model(space)
      self.space.load_from_model(space)
      self.lease.load_from_model(space)
      self.media = Magpie::Media.load_medias_from_model(space)
      self.amenities.load_from_model(space)

      self.property = Magpie::Property.new.load_from_model(space.building)
      self.feed_source_ids = space.feed_source_ids
      self
    end

    def model_attributes_base
      super.merge({
        name: name,
        floor: floor,
        suite: suite,
        status: status,
        available_on: available_on,
        feed_source_ids: feed_source_ids
      })
    end

    def exclude_from_model_attributes
      ['property']
    end

  end
end