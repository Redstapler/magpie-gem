module Magpie
  class Feed < Magpie::Base
    each_entity_class {|entity_class, entity_name, entity_name_plural|

      # e.g. has_many :companies, class: Magpie::Company
      has_many entity_name_plural, class: entity_class

      # e.g. attr_accessor :companies, :companies_by_id
      attr_accessor entity_name_plural, "#{entity_name_plural}_by_id"

      # aggregate validation errors from all entity instances in the feed
      validate do
        self.send(entity_name_plural).each {|entity_instance|
          prefix = "#{entity_instance.class.name.demodulize.underscore}_#{entity_instance.id}"
          unless entity_instance.valid?
            entity_instance.errors.messages.each{|k,v|
              self.errors.messages[(prefix + ' / ' + k.to_s).to_sym] = v
            }
          end
        }
      end

      # e.g. def companies()
      define_method(entity_name_plural) do
        @data[entity_name_plural]
      end

      # e.g. def companies()
      define_method("#{entity_name_plural}_by_id") do
        @data["#{entity_name_plural}_by_id"]
      end

      # e.g. def add_company(attribs)
      # adds to both the companies array and companies_by_id hash
      define_method("add_#{entity_name}") do |attribs={}|
        attribs[:feed_provider] = self.feed_provider
        item = entity_class.new.set_attributes(attribs, entity_name)
        throw "Must specify id in the attributes for add_#{entity_name}" unless item.id.present?
        self.send("add_#{entity_name}_instance", item)
      end

      define_method("add_#{entity_name}_instance") do |item|
        @data[entity_name_plural] << item
        @data["#{entity_name_plural}_by_id"][item.id] = item
        item
      end      
    }

    attr_accessor :feed_provider
    
    def initialize(attributes={})
      super
      @data = {}
      Magpie::Base.each_entity_class {|entity_class, entity_name, entity_name_plural|
        # e.g. @companies = []
        @data[entity_name_plural] = []

        # e.g. @companies_by_id = {}
        @data["#{entity_name_plural}_by_id"] = {}
      }
    end

    def from_json(json, context=nil)
      obj = JSON.parse(json)

      Magpie::Base.each_entity_class {|entity_class, entity_name, entity_name_plural|
        instances = (obj[entity_name_plural] || {}).map do |c|
          model = entity_class.new
          model.set_attributes(c, entity_name)
          model.instance_eval{ @feed_provider ||= obj['feed_provider'] }
          model
        end
        instances.each {|instance|
          # add each instance using the add_ method so it gets addes to both the list (e.g. @companies) and the hash (e.g. @companies_by_id)
          self.send("add_#{entity_name}_instance", instance)
        }
      }
      self.feed_provider = obj['feed_provider']

      self
    end

    def as_json(options={})
      {
        feed_provider: feed_provider,
        companies: companies,
        people: people,
        properties: properties,
        units: units
      }
    end
  end
end