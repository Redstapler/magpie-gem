require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Magpie::Rate" do
  [
    {name: "only min rate", json: "{\"min\":\"1.0\"}", min_rate: 1.0, max_rate: nil, rate: 1.0, to_json: "1.0"},
    {name: "only max rate", json: "{\"max\":\"1.0\"}", min_rate: 1.0, max_rate: 1.0, rate: 1.0, to_json: "1.0"},
    {name: "both min and rates", json: "{\"max\":\"4.0\", \"min\":\"1.0\"}", min_rate: 1.0, max_rate: 4.0, rate: nil, to_json: "{\"min\":1.0,\"max\":4.0}"},
    {name: "only rate", json: "\"1.0\"", min_rate: 1.0, max_rate: nil, rate: 1.0, to_json: "1.0"},

    {name: "only min rate (float values)", json: "{\"min\":1.0}", min_rate: 1.0, max_rate: nil, rate: 1.0, to_json: "1.0"},
    {name: "only max rate (float values)", json: "{\"max\":1.0}", min_rate: 1.0, max_rate: 1.0, rate: 1.0, to_json: "1.0"},
    {name: "both min and rates (float values)", json: "{\"max\":4.0, \"min\":1.0}", min_rate: 1.0, max_rate: 4.0, rate: nil, to_json: "{\"min\":1.0,\"max\":4.0}"},
    {name: "only rate (float values)", json: "1.0", min_rate: 1.0, max_rate: nil, rate: 1.0, to_json: "1.0"},

  ].each do |test|
    context test[:name] do
      context "from_json" do
        subject {Magpie::Rate.new.from_json(test[:json])}

        it "has correct min rate" do
          subject.min_rate.should == test[:min_rate]
        end

        it "has correct min rate" do
          subject.max_rate.should == test[:max_rate]
        end

        it "has correct rate" do
          subject.rate.should == test[:rate]
        end
      end
    end

    context "to_json" do
      subject {Magpie::Rate.new.from_json(test[:json])}
      it "should generate correct json" do
        subject.to_json.should == test[:to_json]
      end      
    end
  end
end
