require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magpie::Feed" do

  it "produces correct json" do
    feed = Magpie::Feed.new
    property = feed.add_property(id: 'property1')
    property.name = "property 1"

    feed.to_json.should == '{}'
  end

end
