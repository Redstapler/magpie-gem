require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magpie::Property" do

  it "produces correct json" do
    property = Magpie::Property.new
    property.name = "property 1"

    property.to_json.should == "{\"for_lease\":true,\"locked_listing\":false,\"name\":\"property 1\"}"
  end

end
