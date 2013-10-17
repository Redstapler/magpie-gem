module Magpie
  class Unit < Magpie::Entity

    attr_accessor :property

    attr_accessor :property_id, :floor, :suite, :status, :available_on, :contacts, :space, :lease, :media, :amenities
    has_many :contacts, :class => Magpie::Contact
    has_one :space, :class => Magpie::UnitSpace, :context => 'unit'
    has_one :lease, :class => Magpie::UnitLease
    has_many :media, :class => Magpie::Media
    has_one :amenities, :class => Magpie::UnitAmenities, :context => 'unit'
    def load_from_model(space)
      super(space)

      @floor = space.floor
      @suite = space.suite
      @status = space.status
      @available_on = space.available_on
      @contacts = Magpie::Contact.load_contacts_from_model(space)
      @space = Magpie::UnitSpace.new.load_from_model(space)
      @lease = Magpie::UnitLease.new.load_from_model(space)
      @media = Magpie::Media.load_medias_from_model(space)
      @amenities = Magpie::UnitAmenities.new.load_from_model(space)

      @property = Magpie::Property.new.load_from_model(space.building)
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

    def lookup_building(property_id)
      Building.where('feed_provider = ?', @feed_provider).where('feed_id = ?', property_id.to_s).first
    end

    def do_save(options={})
      raise 'Must set property on unit before saving' unless @property
      @building = @property.model
      # Create building if needed
      action = :update
      unless @model
        action = :create
        @model ||= @building.spaces.build
      end

      # Update building attribute
      @model.use_types = use_types
      @model.assign_attributes(model_attributes, :without_protection => true)
      if @model.changed?
        validate
        @model.save! 
      end

      @model.reload

      # Upload media assets
      options[:type] = 'Space'
      upload_media_assets(@model, options)

      # Update contacts
      update_contacts(@model, @contacts)

      action
    end
  end
end