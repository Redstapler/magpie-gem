# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "magpie-gem"
  s.version = "0.1.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Amol Kelkar"]
  s.date = "2013-10-17"
  s.description = "OfficeSpace Magpie Library"
  s.email = "tech@officespace.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/extensions/enumerable.rb",
    "lib/magpie-gem.rb",
    "lib/magpie-gem/base.rb",
    "lib/magpie-gem/company.rb",
    "lib/magpie-gem/contact.rb",
    "lib/magpie-gem/entity.rb",
    "lib/magpie-gem/feed.rb",
    "lib/magpie-gem/location.rb",
    "lib/magpie-gem/media.rb",
    "lib/magpie-gem/person.rb",
    "lib/magpie-gem/postal_address.rb",
    "lib/magpie-gem/property.rb",
    "lib/magpie-gem/property_amenities.rb",
    "lib/magpie-gem/property_built.rb",
    "lib/magpie-gem/property_floor_load_ratio.rb",
    "lib/magpie-gem/property_land.rb",
    "lib/magpie-gem/property_lcs.rb",
    "lib/magpie-gem/property_sale.rb",
    "lib/magpie-gem/property_space.rb",
    "lib/magpie-gem/property_space_type.rb",
    "lib/magpie-gem/property_space_type_lease.rb",
    "lib/magpie-gem/property_space_types.rb",
    "lib/magpie-gem/rate.rb",
    "lib/magpie-gem/unit.rb",
    "lib/magpie-gem/unit_amenities.rb",
    "lib/magpie-gem/unit_lease.rb",
    "lib/magpie-gem/unit_space.rb",
    "lib/magpie-gem/unit_space_type.rb",
    "lib/magpie-gem/unit_space_types.rb",
    "magpie-gem.gemspec",
    "spec/magpie-gem_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/redstapler/magpie-gem"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "OfficeSpace Magpie Library"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<activemodel>, [">= 3.1.12"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<activemodel>, [">= 3.1.12"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<activemodel>, [">= 3.1.12"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end

