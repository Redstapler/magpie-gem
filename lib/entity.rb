# Magpie class that corresponds with a real database backed model
class Magpie::Entity < Magpie::Base
  attr_accessor :model, :feed_provider, :id
  validates_presence_of :feed_provider, :id

  def load_from_model(m)
    @model = m
    @feed_provider = m.feed_provider
    @id = m.feed_id.to_s
    self
  end

  def model_attributes_base
    {
      feed_id: @id.to_s,
      feed_provider: @feed_provider,
    }
  end
  
  def validate_model_attributes

  end

  def validate_model_attributes_presence attribs_to_validate, attribs
    prefix = self.class.name.demodulize.underscore
    if self.is_a? Magpie::Entity
      prefix = "#{prefix}_#{@id}"
    end

    attribs_to_validate.each do |attrib|
      self.errors.messages["#{prefix} / model / #{attrib}".to_sym] = ["can't be blank"] if attribs[attrib].blank?
    end
  end

  def lookup_model
    self.class::MODEL_CLASS.where('feed_provider = ?', @feed_provider).where('feed_id = ?', @id.to_s).first
  end

  def valid?
    validate_model_attributes
    super
  end

  def validate
    valid?
    throw "Validation errors: #{self.errors.full_messages}\nmodel = #{self.inspect}" unless self.errors.messages.count == 0
  end
end