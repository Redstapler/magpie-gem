class Magpie::Importer
  cattr_accessor :buildings, :use_types

  # Pass in the location of the Catylist data file for parsing
  def initialize(feed)
    @feed = feed
  end

  #
  # Stuff the data from the feed into the database
  #
  def run!(options = {})
    throw "Validation errors: #{@feed.error_messages}" unless @feed.valid?
    
    cache = {actions: {}}
    speed_up_environment {

      [Magpie::Company, Magpie::Person, Magpie::Property, Magpie::Unit].each {|entity|
        entity_name = entity.name.demodulize.underscore
        entity_plural_name = entity_name.pluralize
        # puts "Processing #{entity_plural_name}..."

        model_class = entity::MODEL_CLASS 

        model_name = model_class.name.demodulize.underscore
        model_plural_name = model_name.pluralize

        all_model_instances = cache["all_model_#{model_plural_name}"] = model_class.select('id, feed_id, feed_override').where(feed_provider: @feed.feed_provider).index_by(&:feed_id)
        model_instances_to_archive = model_class.select('id, feed_id, feed_override').where(feed_provider: @feed.feed_provider).index_by(&:feed_id)
        # puts "model_instances_to_archive = #{model_instances_to_archive}"
        all_by_id = cache["magpie_#{entity_plural_name}_by_id"] = {}
        cache[:actions][entity_name] = actions = {create: 0, update: 0, delete: 0, failed: 0}

        @feed.send(entity_plural_name).each {|entity_instance|
          # puts "Importing #{entity_name} #{entity_instance.id}"
          next if entity_instance.nil?
          
          all_by_id[entity_instance.id.to_s] = entity_instance

          %w(property company).each do |association_type|
            association_id = entity_instance.send("#{association_type}_id") if entity_instance.respond_to?("#{association_type}_id")
            entity_instance.send("#{association_type}=", cache["magpie_#{association_type.pluralize}_by_id"][association_id.to_s]) unless association_id.nil?
          end
          
          begin
            action = entity_instance.save || :failed
            actions[action] += 1
          # rescue Exception => e
          #   actions[:failed] += 1
          #   puts "Failed to save #{entity_name} - #{e}"
          #   puts entity_instance.inspect
          end

          model_instances_to_archive.delete entity_instance.id.to_s
        }
        # puts "archiving #{entity_plural_name} #{model_instances_to_archive.inspect}"
        actions[:delete] = model_instances_to_archive.length
        model_class.where('id in (?)', model_instances_to_archive.collect{|k,v| v.id}).each{|m|
          # puts "archiving #{model_class.name} #{m.id}"
          if m.respond_to?('archive!')
            m.archive!
          else
            m.destroy
          end
        }

      }
    }

    cache[:actions]
  end

  # Turn off functionality we don't need while doing an import
  def speed_up_environment
    PaperTrail.enabled = false
    Submarket.no_bounds_update = true
    Rails.application.config.colorize_logging = false

    yield

    PaperTrail.enabled = true
    Submarket.no_bounds_update = false
  end
end