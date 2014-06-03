require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magpie::UnitLease" do
  context "loads correctly from json" do
    subject {Magpie::UnitLease.new.from_json("{\"type\":\"NNN\",\"rate\":{\"min\":\"1.0\"}}")}

    it "has correct type" do
      subject.type.should == "NNN"
    end

    it "has correct rate" do
      subject.rate.min_rate.should == 1.0
      subject.rate.max_rate.should == nil
      subject.rate.rate.should == 1.0
    end

  end
end
