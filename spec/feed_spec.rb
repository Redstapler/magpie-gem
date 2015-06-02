require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magpie::Feed" do

  it "produces correct json" do
    feed = Magpie::Feed.new
    property = feed.add_property(id: 'property1')
    property.name = "property 1"

    expect(feed.to_json(skip_validations: true)).to eq("{\"feed_provider\":null,\"companies\":[],\"people\":[],\"properties\":[{\"for_lease\":true,\"locked_listing\":false,\"id\":\"property1\",\"name\":\"property 1\"}],\"units\":[]}")
  end

end
