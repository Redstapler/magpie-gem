require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magpie::UnitLease" do
  context "loads correctly from json" do
    subject {Magpie::UnitLease.new.from_json("{\"type\":\"NNN\",\"rate\":{\"min\":\"1.0\"}}")}

    it "has correct type" do
      expect(subject.type).to eq("NNN")
    end

    it "has correct rate" do
      expect(subject.rate.min_rate).to eq(1.0)
      expect(subject.rate.max_rate).to eq(nil)
      expect(subject.rate.rate).to eq(1.0)
    end

    it "generates correct json" do
      expect(subject.to_json).to eq_json("{\"rate\":1.0,\"type\":\"NNN\"}")
    end
  end
end
