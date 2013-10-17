require 'magpie-gem/postal_address.rb'
require 'magpie-gem/location.rb'
module Magpie
  class Company < Magpie::Entity
    has_one :postal_address, class: Magpie::PostalAddress

    DEDUP_ATTRIBUTES = [:name, :city, :state]

    attr_accessor :name, :postal_address, :phone, :fax, :email, :url

    validates_presence_of :name

    def load_from_model(company)
      super
      @id = company.feed_id || company.name
      @name = company.name
      @postal_address = Magpie::PostalAddress.new.load_from_model(company)
      @phone = company.phone
      @fax = company.fax
      @email = company.email
      @url = company.url

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