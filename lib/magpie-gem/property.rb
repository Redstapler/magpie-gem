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
    DEDUP_ATTRIBUTES = [:address, :city, :state]

    attr_accessor :name, :description, :zoning, :tax_id_number, :location, :land, :built, :sale, :space, :media, :amenities, :floor_load_ratio, :contacts
    has_one :location, :class => Magpie::Location
    has_one :land, :class => Magpie::PropertyLand
    has_one :built, :class => Magpie::PropertyBuilt
    has_one :space, :class => Magpie::PropertySpace, :context => 'property'
    has_one :sale, :class => Magpie::PropertySale
    has_one :floor_load_ratio, :class => Magpie::PropertyFloorLoadRatio
    has_many :media, :class => Magpie::Media
    has_many :contacts, :class => Magpie::Contact
    has_one :amenities, :class => Magpie::PropertyAmenities, :context => 'property'

    def load_from_model(building)
      super(building)
      self.name = building.name
      self.description = building.comment
      # updated_at: building.updated_at,
      # active: building.active,
      # owner_company_id: building.owner_company_id,
      # management_company_id: building.management_company_id,
      self.zoning = building.zoning
      self.tax_id_number = building.parcel
      self.location = Magpie::Location.new.load_from_model(building)
      self.land = Magpie::PropertyLand.new.load_from_model(building)
      self.built = Magpie::PropertyBuilt.new.load_from_model(building)
      self.sale = Magpie::PropertySale.new.load_from_model(building)
      self.space = Magpie::PropertySpace.new.load_from_model(building)
      self.media = Magpie::Media.load_medias_from_model(building)
      self.floor_load_ratio = Magpie::PropertyFloorLoadRatio.new.load_from_model(building)
      self.amenities = Magpie::PropertyAmenities.new.load_from_model(building)
      self.contacts = Magpie::Contact.load_contacts_from_model(building)

      self
    end

    def model_attributes_base
      super.merge({
        name: @name,
        comment: @description,
        zoning: @zoning,
        parcel: @tax_id_number
      })
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