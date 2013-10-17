module Magpie
  class Person < Magpie::Entity
    attr_accessor :company

    attr_accessor :id, :name, :email, :phone, :default_role

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
  end
end