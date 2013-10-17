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
      @name = building.name
      @description = building.comment
      # updated_at: building.updated_at,
      # active: building.active,
      # owner_company_id: building.owner_company_id,
      # management_company_id: building.management_company_id,
      @zoning = building.zoning
      @tax_id_number = building.parcel
      @location = Magpie::Location.new.load_from_model(building)
      @land = Magpie::PropertyLand.new.load_from_model(building)
      @built = Magpie::PropertyBuilt.new.load_from_model(building)
      @sale = Magpie::PropertySale.new.load_from_model(building)
      @space = Magpie::PropertySpace.new.load_from_model(building)
      @media = Magpie::Media.load_medias_from_model(building)
      @floor_load_ratio = Magpie::PropertyFloorLoadRatio.new.load_from_model(building)
      @amenities = Magpie::PropertyAmenities.new.load_from_model(building)
      @contacts = Magpie::Contact.load_contacts_from_model(building)

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

    def do_save(options={})
      # Create building if needed
      action = :update
      unless @model
        action = :create
        @model ||= Building.new
      end

      # Update building attribute
      @model.use_types = use_types
      @model.assign_attributes(model_attributes, :without_protection => true)
      if @model.changed?
        @model.save! 
      end
      @model.reload

      # Amenities
      @model.amenities = @amenities.amenities.except("Paid parking", "Sprinklers", "HVAC", "Elevators", "Sewer", "Doors").collect {|name, value|
        Amenity.find_or_create_by_name(name)
      }

      validate
      @model.save!

      # Upload media assets
      upload_media_assets(@model, options)

      # Assign people
      update_contacts(@model, @contacts)

      action
    end

  end
end