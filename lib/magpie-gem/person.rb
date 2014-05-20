module Magpie
  class Person < Magpie::Entity
    attr_accessor :company

    attr_accessor :id, :name, :email, :phone, :default_role, :company_id

    DEDUP_ATTRIBUTES = [:email]

    def initialize
    end

    def set_attributes(data, context=nil)
      super(data)
      self.id = @email if @id.blank?
      self
    end

    def load_from_model(person)
      super(person)
      self.id = person.feed_id
      self.id = person.email if self.id.blank?
      self.name = person.name
      self.email = person.email
      self.phone = person.phone
      self.default_role = person.default_role

      self.company = Magpie::Company.new.load_from_model(person.company)
      self.company_id = self.company.id

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

    def exclude_from_model_attributes
      ['company']
    end

    def validate_model_attributes
      attribs = model_attributes
      validate_model_attributes_presence [:name, :email, :default_role], attribs
    end
  end
end