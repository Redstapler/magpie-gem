class Magpie::Person < Magpie::Entity
  attr_accessor :company

  attr_accessor :id, :name, :email, :phone, :default_role

  MODEL_CLASS = ::Person
  DEDUP_ATTRIBUTES = [:email]

  def set_attributes(data, context=nil)
    super(data)
    @id = @email if @id.blank?
    self
  end

  def load_from_model(person)
    super(person)
    @id = person.feed_id
    @id = person.email if @id.blank?
    @name = person.name
    @email = person.email
    @phone = person.phone
    @default_role = person.default_role
    self
  end

  def model_attributes_base
    super.merge({
      name: @name,
      email: @email,
      phone: @phone,
      default_role: @default_role,
      feed_id: @id || @email
    })
  end

  def validate_model_attributes
    attribs = model_attributes
    validate_model_attributes_presence [:name, :email, :default_role], attribs
  end

  def do_save(options={})
    action = :update
    unless @model
      action = :create
      @model ||= @company.model.people.build if @company
      @model ||= Person.new
    end

    validate
    @model.update_attributes!(model_attributes, :without_protection => true)
    
    return action
  end
end
