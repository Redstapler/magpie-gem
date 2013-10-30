require 'magpie-gem/unit_space.rb'
require 'magpie-gem/unit_lease.rb'
require 'magpie-gem/contact.rb'
require 'magpie-gem/media.rb'
require 'magpie-gem/unit_amenities.rb'

module Magpie
  class Unit < Magpie::Entity
    DEDUP_ATTRIBUTES = nil
    
    attr_accessor :property

    attr_accessor :property_id, :floor, :suite, :status, :available_on, :contacts, :space, :lease, :media, :amenities
    has_many :contacts, :class => Magpie::Contact
    has_one :space, :class => Magpie::UnitSpace, :context => 'unit'
    has_one :lease, :class => Magpie::UnitLease
    has_many :media, :class => Magpie::Media
    has_one :amenities, :class => Magpie::UnitAmenities, :context => 'unit'

    def initialize
      self.contacts = []
      self.space = Magpie::UnitSpace.new
      self.lease = Magpie::UnitLease.new
      self.media = []
      self.amenities = Magpie::UnitAmenities.new
    end

    def load_from_model(space)
      super(space)

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
      self
    end

    def model_attributes_base
      super.merge({
        floor: @floor,
        suite: @suite,
        status: status,
        available_on: @available_on
      })
    end

    def exclude_from_model_attributes
      ['property']
    end

    def parse_date(d)
      d.to_s.match(%r{\d{4}\-\d{1,2}\-\d{1,2}}) ? Date.strptime(d.to_s, '%Y-%m-%d') : nil
    end

    def status
      case @status
      when 'Lease Pending'
        'lease_pending'
      else
        'available'
      end
    end
  end
end