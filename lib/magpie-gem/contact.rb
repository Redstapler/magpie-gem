module Magpie
  class Contact < Magpie::Base
    attr_accessor :role, :email

    def self.load_contacts_from_model(model)
      model.contacts.collect do |c|
        Magpie::Contact.new(email: c.person.email, role: c.role)
      end
    end

  end
end