RSpec.describe Checker::ActiveCheckBuilder do
  describe "#build", :focus do
    before do
      differ = Checker::Differ.new(
        Dir.pwd + "/..",
        "e0b1b50d4ca5636a97a5714bfb9f1618ca7a3746",
        "26c2d0190483e9ba1795dd779bfb110593c18342"
      )
      config = Checker::Config.new("spec/fixtures/self_test.yaml")
      config.parse
      builder = Checker::ActiveCheckBuilder.new(config, differ)
      @checklist = builder.build
    end
    it "filters the triggers to only fired ones" do
      @checklist
    end
    it "filters the checklist to only modified paths" do
      puts @checklist.list
      expect(@checklist.list).not_to be_empty
      expect(@checklist.list.first.checks).not_to be_empty
      expect(@checklist.list.first.checks.first.check).to eq(
        "I fire for everything"
      )
    end
  end
end
