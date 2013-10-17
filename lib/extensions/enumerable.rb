# FROM https://github.com/rails/rails/blob/0beb55183b379cd63f25a923a9a6301d629b15cf/activesupport/lib/active_support/core_ext/enumerable.rb
# require 'active_support/core_ext/object/deep_dup'
module Enumerable
  # Remove nil and blank objects
  #
  # Example
  #
  #   Arrays
  #   [1, 2, nil, "", 3, [4, 5, nil]].clean
  #   # => [1, 2, 3, [4, 5]]
  #
  #   Hashes
  #   Hash[:one => 1, :two => nil, :three => 3, :four => { :a => 'a', :b => '' }].clean
  #   # => {:one => 1, :three => 3, :four => { :a => 'a' } }
  #
  #   Mixed Hashes and Arrays
  #   [Hash[:one => nil, :two => 2], true].clean
  #   # => [{:two => 2}, true]
  # def clean
  #   deep_dup.clean!
  # end

  def clean!
    reject! do |item|
      obj = is_a?(Hash) ? self[item] : item
      if is_a?(Hash)        
        self[item] = false if obj == "false"
        self[item] = true if obj == "true"
      end

      if obj.respond_to?(:reject!)
        obj.clean!
        obj.blank? || obj == "null"
      else
        (obj.blank? || obj == "null") && !obj.is_a?(FalseClass)
      end
    end
    self
  end
end
