require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MagpieGem" do
  it "loads fine" do
    expect(Magpie::Base).not_to eq(nil)
    expect(Magpie::Unit).not_to eq(nil)
    expect(Magpie::UnitSpace).not_to eq(nil)
  end
end
