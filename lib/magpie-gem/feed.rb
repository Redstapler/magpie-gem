module Magpie
  class Feed < Magpie::Base
    has_many :companies, class: Magpie::Company
    has_many :people, class: Magpie::Person
    has_many :properties, class: Magpie::Property
    has_many :units, class: Magpie::Unit
    attr_accessor :companies, :people, :properties, :units, :feed_provider

    validate do
      [:companies, :people, :properties, :units].each {|entity_name_plural|
        self.send(entity_name_plural).each {|entity|
          prefix = "#{entity.class.name.demodulize.underscore}_#{entity.id}"
          unless entity.valid?
            entity.errors.messages.each{|k,v|
              self.errors.messages[(prefix + ' / ' + k.to_s).to_sym] = v
            }
          end
        }
      }
    end
    
    def initialize(attributes={})
      super
      self.companies = []
      self.people = []
      self.properties = []
      self.units = []
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json)

      self.companies = (obj['companies'] || {}).collect{|c| model = Magpie::Company.new; model.set_attributes(c, 'company'); model.feed_provider = obj['feed_provider']; model}
      self.people = (obj['people'] || {}).collect{|c| model = Magpie::Person.new; model.set_attributes(c, 'person'); model.feed_provider = obj['feed_provider']; model}
      self.properties = (obj['properties'] || {}).collect{|c| model = Magpie::Property.new; model.set_attributes(c, 'property'); model.feed_provider = obj['feed_provider']; model}
      self.units = (obj['units'] || {}).collect{|c| model = Magpie::Unit.new; model.set_attributes(c, 'unit'); model.feed_provider = obj['feed_provider']; model}
      self.feed_provider = obj['feed_provider']

      self
    end

    # def self.from_hash(data)
    #   feed = Magpie::Feed.new data['feed_provider']
    #   data['companies'].each{|p| feed.companies << Magpie::Company.from_hash(data['feed_provider'], p)} if data['companies'].present?
    #   data['people'].each{|p| feed.people << Magpie::Person.from_hash(data['feed_provider'], p)} if data['people'].present?
    #   data['properties'].each{|p| feed.properties << Magpie::Property.from_hash(data['feed_provider'], p)}
    #   data['units'].each{|u| feed.units << Magpie::Unit.from_hash(data['feed_provider'], u)}
    #   feed
    # end

    # def initialize(feed_provider)
    #   @feed_provider = feed_provider
    #   @companies = []
    #   @people = []
    #   @properties = []
    #   @units = []
    # end

    # def as_json(params)
    #   {feed_provider: @feed_provider, companies: @companies, people: @people, properties: @properties, units: @units}.as_json(params)
    # end
  end
end