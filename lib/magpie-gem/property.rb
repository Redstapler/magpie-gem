require 'magpie-gem/property_land.rb'
require 'magpie-gem/property_built.rb'
require 'magpie-gem/property_space.rb'
require 'magpie-gem/property_sale.rb'
require 'magpie-gem/property_floor_load_ratio.rb'
require 'magpie-gem/media.rb'
require 'magpie-gem/contact.rb'
require 'magpie-gem/property_amenities.rb'

module Magpie
  class Property < Magpie::Entity
    DEDUP_ATTRIBUTES = [:formatted_long_address]

    attr_accessor :for_lease, :name, :description, :zoning, :tax_id_number, :location, :land, :built, :sale, :space,
                  :media, :amenities, :floor_load_ratio, :contacts, :locked_listing, :last_updated

    has_one :location, :class => Magpie::Location
    has_one :land, :class => Magpie::PropertyLand
    has_one :built, :class => Magpie::PropertyBuilt
    has_one :space, :class => Magpie::PropertySpace, :context => 'property'
    has_one :sale, :class => Magpie::PropertySale
    has_one :floor_load_ratio, :class => Magpie::PropertyFloorLoadRatio
    has_many :media, :class => Magpie::Media
    has_many :contacts, :class => Magpie::Contact
    has_one :amenities, :class => Magpie::PropertyAmenities, :context => 'property'

    def initialize
      self.for_lease = true
      self.location = Magpie::Location.new
      self.land = Magpie::PropertyLand.new
      self.built = Magpie::PropertyBuilt.new
      self.sale = Magpie::PropertySale.new
      self.space = Magpie::PropertySpace.new
      self.media = []
      self.floor_load_ratio = Magpie::PropertyFloorLoadRatio.new
      self.amenities = Magpie::PropertyAmenities.new
      self.contacts = []
      self.locked_listing = false
    end

    def load_from_model(building)
      super(building)
      self.name = building.name
      self.description = building.comment
      self.for_lease = :published.eql? building.visibility.to_sym
      self.locked_listing = building.locked_listing
      # updated_at: building.updated_at,
      # active: building.active,
      # owner_company_id: building.owner_company_id,
      # management_company_id: building.management_company_id,
      self.zoning = building.zoning
      self.tax_id_number = building.parcel
      self.location.load_from_model(building)
      self.land.load_from_model(building)
      self.built.load_from_model(building)
      self.sale.load_from_model(building)
      self.space.load_from_model(building)
      self.media = Magpie::Media.load_medias_from_model(building)
      self.floor_load_ratio.load_from_model(building)
      self.amenities.load_from_model(building)
      self.contacts = Magpie::Contact.load_contacts_from_model(building)
      self
    end

    def model_attributes_base
      super.merge({
        name: @name,
        comment: @description,
        zoning: @zoning,
        parcel: @tax_id_number,
        locked_listing: @locked_listing,
        modified_on: last_updated
      })
    end

    def last_updated
      case @last_updated
      when String
        DateTime.parse(@last_updated)
      when Time, Date, nil
        @last_updated
      else
        raise TypeError, "Unhandled last_updated type of class: #{@last_updated.class} "
      end
    end

    def sanitize_model_attributes(attrs)
      attrs[:address] = attrs.delete(:address1)
      attrs.delete(:address2)
      attrs
    end

    def validate_model_attributes
      attribs = model_attributes
      validate_model_attributes_presence [:address, :city, :state, :postal_code], attribs
    end
  end
end