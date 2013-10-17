require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MagpieGem" do
  it "loads fine" do
    Magpie::Base.should_not == nil
    Magpie::Unit.should_not == nil
  end
end
