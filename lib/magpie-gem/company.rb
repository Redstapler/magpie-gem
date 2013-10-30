require 'magpie-gem/postal_address.rb'
require 'magpie-gem/location.rb'
module Magpie
  class Company < Magpie::Entity
    has_one :postal_address, class: Magpie::PostalAddress

    DEDUP_ATTRIBUTES = [:name, :city, :state]

    attr_accessor :name, :postal_address, :phone, :fax, :email, :url

    validates_presence_of :name

    def initialize
      self.postal_address = Magpie::PostalAddress.new
    end

    def load_from_model(company)
      super
      self.id = company.feed_id || company.name
      self.name = company.name
      self.postal_address.load_from_model(company)
      self.phone = company.phone
      self.fax = company.fax
      self.email = company.email
      self.url = company.url

      self
    end

    def model_attributes_base
      super.merge({
        feed_id: id || name,
        feed_provider: feed_provider,
        name: name,
        phone: phone,
        fax: fax,
        email: email,
        url: url
      })
    end
  end
end